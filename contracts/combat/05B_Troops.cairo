%lang starknet

from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import assert_le
from starkware.cairo.common.pow import pow

# namespace constants deliberately start at 1 to
# 1) translate in a straighforward way to "human, 1-based index" land
# 2) to differentiate between uninitialized value (i.e. 0 in Cairo)

namespace TroopId:
    const Watchman = 1
    const Guard = 2
    const GuardCaptain = 3
    const Squire = 4
    const Knight = 5
    const KnightCommander = 6
    const Scout = 7
    const Archer = 8
    const Sniper = 9
    const Scorpio = 10
    const Baillista = 11
    const Catapult = 12
    const Apprentice = 13
    const Mage = 14
    const Arcanist = 15
    const GrandMarshal = 16
end

namespace TroopType:
    const Melee = 1
    const Ranged = 2
    const Siege = 3
end

struct TroopStats:
    member packed : felt
end

const AGILITY_SHIFT = 0x100
const ATTACK_SHIFT = 0x10000
const DEFENSE_SHIFT = 0x1000000
const VITALITY_SHIFT = 0x100000000
const WISDOM_SHIFT = 0x10000000000

# returns a Troop's tier, agility, attack, defence, vitality and wisdom
# statisticts, bit packed in a single felt value
@view
func get_troop_stats{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(troop_id : felt) -> (
        stats : TroopStats):
    if troop_id == TroopId.Watchman:
        let (p) = pack_troop_stats(1, 1, 1, 3, 4, 1)
        return (TroopStats(packed=p))
    end

    if troop_id == TroopId.Guard:
        let (p) = pack_troop_stats(2, 2, 2, 6, 8, 2)
        return (TroopStats(packed=p))
    end

    if troop_id == TroopId.GuardCaptain:
        let (p) = pack_troop_stats(3, 4, 4, 12, 16, 4)
        return (TroopStats(packed=p))
    end

    return (TroopStats(packed=0))
end

func pack_troop_stats{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        tier : felt, agility : felt, attack : felt, defense : felt, vitality : felt,
        wisdom : felt) -> (packed : felt):
    alloc_locals

    assert_le(tier, 255)
    assert_le(agility, 255)
    assert_le(attack, 255)
    assert_le(defense, 255)
    assert_le(vitality, 255)
    assert_le(wisdom, 255)

    # TODO: mention limitations of this approach
    #       short comment about how it works
    # agility << 8 == agility * 2**8
    # attack << 16 == attack * 2**16

    tempvar r = tier  # no need to shift tier
    tempvar agility_shifted = agility * AGILITY_SHIFT
    tempvar r = r + agility_shifted
    tempvar attack_shifted = attack * ATTACK_SHIFT
    tempvar r = r + attack_shifted
    tempvar defense_shifted = defense * DEFENSE_SHIFT
    tempvar r = r + defense_shifted
    tempvar vitality_shifted = vitality * VITALITY_SHIFT
    tempvar r = r + vitality_shifted
    tempvar wisdom_shifted = wisdom * WISDOM_SHIFT
    tempvar r = r + wisdom_shifted

    return (r)
end
