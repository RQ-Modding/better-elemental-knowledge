-- Better Elemental Knowledge: one skill row in place of the five Brawling Knowledges (Brawlers),
-- and one in place of Fire, Ice and Electric Arrows (Kalar Gunners such as Aegis). A player's
-- suggestion; notes/plans/plan-better-elemental-knowledge.md in the workspace.
-- API reference: https://rq-modding.github.io/rq-modding-docs/reference/
--
-- What the game does (Ｔ購入スキル登録, 物理属性計算): a Brawler buys each Brawling Knowledge for 1
-- point from level 10; a Gunner with Kalar Species each elemental Arrow for 3. When the defender's
-- weakness is known and no guard took the hit, Element Strike (Brawling) or a basic attack
-- (Arrows) takes the weakness's element when the attacker holds that element's skill. Each is a
-- skill row, and a character holds at most 17.
--
-- The new skill does the same for every element of its set (rq.combat.on_element). Its price is
-- the set's less what the character holds of it, at least 1 point (a row of price 0 is not for
-- sale). Buying it erases those single ones with no points back (they came off the price) and
-- writes their purchase records into the new row (rq.chara.set_cost, loader 2.53.0), so an ERASE
-- with Skill Removal Payback gives back all that was paid for the set. Once it is held, the single
-- ones leave the buy list.

local ids = rq.ids
local E = ids.element
local ELEMENT_STRIKE = ids.skill.ELEMENT_STRIKE -- 145
local KALAR_SPECIES = ids.skill.KALAR_SPECIES   -- 290

local BRAWLING = rq.skill.define({
  id = "better-elemental-knowledge:brawling",
  kind = "knowledge",
  name = "Elemental Brawling Knowledge",
  flavor = "",
  desc = "Every element answers your fists: Element Strike$"
    .. "deals the damage of the enemy's known weakness.$$"
    .. "Target:\tSelf$"
    .. "Effect:\tFire, Ice, Electric, Light and Darkness$"
    .. "\tBrawling Knowledge in one",
})

local ARROWS = rq.skill.define({
  id = "better-elemental-knowledge:arrows",
  kind = "knowledge",
  name = "Elemental Arrows",
  flavor = "",
  desc = "If the enemy is known to be weak to fire, ice$"
    .. "or electricity, Ranged Attacks 1-4 will deal$"
    .. "that damage.$$"
    .. "Target:\tSelf$"
    .. "Effect:\tFire, Ice and Electric Arrows in one",
})

-- Each set: the new skill, the single ones it takes the place of (in the buy list's order) with
-- their element, a single one's price, the level, who can buy it, and which hits take the weakness.
local SETS = {
  {
    skill = BRAWLING,
    singles = {
      { id = ids.skill.FIRE_BRAWLING_KNOWLEDGE, element = E.FIRE },          -- 331
      { id = ids.skill.ICE_BRAWLING_KNOWLEDGE, element = E.ICE },            -- 332
      { id = ids.skill.ELECTRIC_BRAWLING_KNOWLEDGE, element = E.ELECTRIC },  -- 333
      { id = ids.skill.LIGHT_BRAWLING_KNOWLEDGE, element = E.LIGHT },        -- 334
      { id = ids.skill.DARKNESS_BRAWLING_KNOWLEDGE, element = E.DARKNESS },  -- 335
    },
    price = 1,
    level = 10,
    can = function(ctx) return ctx.class == ids.class.BRAWLER end,
    hit = function(ctx) return ctx.skill == ELEMENT_STRIKE end,
  },
  {
    skill = ARROWS,
    singles = {
      { id = ids.skill.FIRE_ARROWS, element = E.FIRE },          -- 254
      { id = ids.skill.ICE_ARROWS, element = E.ICE },            -- 255
      { id = ids.skill.ELECTRIC_ARROWS, element = E.ELECTRIC },  -- 256
    },
    price = 3,
    level = 1,
    can = function(ctx)
      return ctx.class == ids.class.GUNNER and rq.chara.rank(ctx.iic, KALAR_SPECIES) >= 1
    end,
    -- As the game: the basic flag (Ranged Attack, and Melee Attack too), whatever the text says.
    hit = function(ctx) return ctx.basic end,
  },
}

for _, set in ipairs(SETS) do
  set.single, set.covers = {}, {}
  for _, s in ipairs(set.singles) do
    set.single[s.id] = true
    set.covers[s.element] = true
  end
  set.full = set.price * #set.singles
  rq.skill.sort_as(set.skill, set.singles[1].id)
end

local function holds(iic, skill)
  return rq.chara.rank(iic, skill) >= 1
end

-- The single ones of a set the character holds.
local function held(iic, set)
  local n = 0
  for _, s in ipairs(set.singles) do
    if holds(iic, s.id) then n = n + 1 end
  end
  return n
end

-- The new skill's price for the character now: the set's less what it holds, at least 1.
local function price(iic, set)
  return math.max(1, set.full - set.price * held(iic, set))
end

rq.chara.on_offer(function(ctx)
  local rows = {}
  for _, set in ipairs(SETS) do
    if holds(ctx.iic, set.skill) then
      -- The game lists a single one while it is not held: drop it, the new skill covers it.
      for _, row in ipairs(rq.chara.offers()) do
        if set.single[row.skill] then rq.chara.set_offer(row.index, 0, 0) end
      end
    elseif set.can(ctx) then
      local p = price(ctx.iic, set)
      rows[#rows + 1] = { skill = set.skill, cost = p, level = set.level, points = p }
    end
  end
  return rows
end)

-- Erases the single ones of a set the character holds, with no points back, and writes their
-- purchase records into the new skill's row. Returns how many were erased and the new record.
local function fold(iic, set, record)
  local rows = {}
  for _, s in ipairs(rq.chara.slots(iic)) do
    if s.skill > 0 then rows[s.skill] = s end
  end
  local total, erased = math.max(record, 0), 0
  for _, s in ipairs(set.singles) do
    local r = rows[s.id]
    if r then
      if r.cost > 0 then total = total + r.cost end
      if rq.chara.forget(iic, s.id) then erased = erased + 1 end
    end
  end
  if total == 0 then total = record end -- a skill a mod gave (-1) keeps its mark
  rq.chara.set_cost(iic, set.skill, total)
  if erased > 0 then
    rq.log(("Better Elemental Knowledge: %s of character %d took the place of %d skill(s), record %d")
      :format(rq.skill.get(set.skill).name, iic, erased, total))
  end
  return erased, total
end

rq.chara.on_learn(function(ctx)
  if not ctx.new then return end
  for _, set in ipairs(SETS) do
    if ctx.skill == set.skill then fold(ctx.iic, set, ctx.cost) end
  end
end)

-- As the game's own check, for real hits and the forecast: the weakness, or nil to leave the hit.
local function pick(ctx)
  if not ctx.known or ctx.guarded or ctx.weakness == 0 then return nil end
  for _, set in ipairs(SETS) do
    if set.covers[ctx.weakness] and set.hit(ctx) and holds(ctx.attacker, set.skill) then
      return ctx.weakness
    end
  end
  return nil
end

rq.combat.on_element(pick)

rq.log(("Better Elemental Knowledge: Elemental Brawling Knowledge %d, Elemental Arrows %d")
  :format(BRAWLING, ARROWS))

return {
  BRAWLING = BRAWLING,
  ARROWS = ARROWS,
  SETS = SETS,
  price = price,
  held = held,
  fold = fold,
  pick = pick,
}
