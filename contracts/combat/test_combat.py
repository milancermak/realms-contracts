import asyncio
from collections import namedtuple
import struct
import os

import pytest
from starkware.starknet.testing.starknet import Starknet, StarknetContract


Troop = namedtuple('Troop', ['tier', 'agility', 'attack', 'defense', 'vitality', 'wisdom'])

WATCHMAN = Troop(1, 1, 1, 3, 4, 1)
GUARD = Troop(2, 2, 2, 6, 8, 2)
GUARD_CAPTAIN = Troop(3, 4, 4, 12, 16, 4)
TROOPS = [WATCHMAN, GUARD, GUARD_CAPTAIN]


def contract_path(contract_name: str) -> str:
    here = os.path.abspath(os.path.dirname(__file__))
    return os.path.join(here, contract_name)


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
async def starknet() -> Starknet:
    starknet = await Starknet.empty()
    return starknet


@pytest.fixture(scope="module")
async def troops_state(starknet) -> StarknetContract:
    contract_src = contract_path("05B_Troops.cairo")
    return await starknet.deploy(source=contract_src)


def pack_troop(troop: Troop) -> int:
    return int.from_bytes(struct.pack('<6b', *troop), 'little')


@pytest.mark.asyncio
async def test_get_troop_stats(troops_state):
    for idx, troop in enumerate(TROOPS):
        tx = await troops_state.get_troop_stats(idx + 1).invoke()
        troop_stats = tx.result.stats
        assert pack_troop(troop) == troop_stats.packed
