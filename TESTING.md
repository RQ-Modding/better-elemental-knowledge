# Testing Better Elemental Knowledge

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Loading better-elemental-knowledge` and the line
`Better Elemental Knowledge: Elemental Brawling Knowledge <n>, Elemental Arrows <n>`.

## What it adds

- **Controls:** no buttons and no `rq.agent.control` ids. Do not invent controls for it.
- **Buy list rows** in the skill window (the game's own rows, bought with its own buy button):
  - Elemental Brawling Knowledge: Brawlers (class 7), level 10, 5 points less 1 per Brawling
    Knowledge held, at least 1.
  - Elemental Arrows: Gunners (class 3) with Kalar Species, any level, 9 points less 3 per Fire,
    Ice or Electric Arrows held, at least 1.
- **After a purchase:** the single ones the new skill covers are erased (no points back), and the
  log says `Better Elemental Knowledge: <skill> of character <n> took the place of <k> skill(s),
  record <points>`. The single ones are no longer in that character's buy list.
- **In a fight:** with the enemy's weakness known and no guard, Element Strike or a basic attack
  of a holder deals the weakness's element (the log adds " (Attribute weakness)").

## How to check it

1. A Brawler (Biscuitta, Kibako) at level 10 or more: the skill window's buy list has Elemental
   Brawling Knowledge at its price. A Fighter's has not.
2. Buy it: the points go down by the price, the single Brawling Knowledges leave the skill list and
   the buy list, and the new skill shows as one white row.
3. Start a fight, make the enemy's weakness known (Weakness Search, or Rebecca Copley QoL), and use
   Element Strike: the hit takes the weakness's element.
4. Aegis: Elemental Arrows for 1 point folds her three elemental Arrows; her Ranged Attack on a
   known fire, ice or electric weakness takes it. Not light or darkness.

## Forcing it for a test

`rq.chara.learn(iic, mod.BRAWLING)` buys it as the window does. `rq.mod.get("better-elemental-knowledge")`
returns `BRAWLING`, `ARROWS`, `SETS`, `price(iic, set)`, `held(iic, set)`,
`fold(iic, set, record)` and `pick(ctx)` (the `rq.combat.on_element` callback: the element it
gives a hit, or nil).

## Test Lab

`elemental-knowledge` (with this mod installed): the skills, the buy list for a Brawler, a Fighter
and the Kalar Gunners, a purchase through the skill window, Kibako's fold for 1 point, the hits on
each element, the forecast, Skill Again, Skill Removal Payback and Loadouts.
