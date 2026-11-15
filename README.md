# Better Elemental Knowledge

One skill row for a whole set of elemental skills, so Brawlers and Aegis keep room for others.

## What it changes

A character holds at most 17 skills. A Brawler who wants Element Strike to hit every weakness
needs all five Brawling Knowledges, five rows; Aegis's Fire, Ice and Electric Arrows take three.
This mod adds two white skills to the skill window's buy list, each the whole set in one row:

| Skill | Who can buy it | Level | Price |
| --- | --- | --- | --- |
| **Elemental Brawling Knowledge**: Fire, Ice, Electric, Light and Darkness Brawling Knowledge in one | Brawlers | 10 | 5 points |
| **Elemental Arrows**: Fire, Ice and Electric Arrows in one | Gunners with Kalar Species (Aegis, Reset Kalar) | any | 9 points |

- They work as the single ones do: when the enemy's weakness is known and no guard took the hit,
  Element Strike (Elemental Brawling Knowledge) or a basic attack (Elemental Arrows) deals the
  weakness's element, with the game's +50%, "(Attribute weakness)" and the big number. The battle
  forecast shows it too.
- The price drops by what the character already holds of the set (1 point per Brawling
  Knowledge, 3 per Arrow), down to 1 point. Buying it erases those single ones, with no points
  back since they came off the price, so the set costs the same in all. Kibako, who starts with
  the five Brawling Knowledges, folds them into one row for 1 point; Aegis her three Arrows for 1.
- Once a character holds the new skill, the single ones leave the buy list.
- Like any purchase, it needs a free skill row: on a full list the game says "No open skill
  slots." Erase a skill outside the set first (erasing one of the set raises the price); the
  purchase then frees the others.
- Erasure Arrows is not part of the set: it removes buffs, it does not change the element.

## With other mods

- **Skill Removal Payback:** the single ones the purchase erases give nothing back (they came off
  the price). Erasing the new skill gives back everything paid for the set: the new skill's price
  and what the single ones it replaced had cost.
- **Loadouts:** a loadout with the new skill buys it as any other skill. A loadout saved with
  single ones cannot be loaded on a character who holds the new skill, since the single ones are
  no longer for sale: Loadouts names them; wipe the slot and save it again.
- **Morurun's reset and Skill Again** take the new skill away like any skill bought, and give back
  the starting ones (Kibako's and Aegis's); the new skill is for sale again.

## Keys and settings

None.

## Saves

The two skills are skill rows of the characters who buy them, at numbers the loader gives the mod
(700 to 999). Without the mod those rows show empty skills, Element Strike and the basic attacks
lose the elements, and the single ones the purchase erased have to be bought again (Kibako's and
Aegis's come back with Morurun's reset or Skill Again).

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.53.0** or newer. Extract the
release zip into the game's `mods` folder, so that you have
`mods/better-elemental-knowledge/mod.json`.

## How it works

`rq.skill.define` makes the two skills and `rq.chara.on_offer` puts them in the buy list (and drops
the single ones once the new skill is held). `rq.chara.on_learn` erases the single ones a purchase
replaces (`rq.chara.forget`) and writes their purchase records into the new row
(`rq.chara.set_cost`). `rq.combat.on_element` gives the hit the weakness's element, as the game's
own check does for the single ones.

## License

MIT, see [LICENSE](LICENSE).
