--deck skins
SMODS.Atlas({key = "tobyaaasdecks", path = "tobyaaas_decks.png", px = 71, py = 95})
SMODS.Atlas({key = "modicon", path = "tobyaaasdeckicon.png", px = 34, py = 34}):register()


------------------------------------------------------------------------------------------------------------------------------------------------------------------
--rote deck definitions
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--red deck
--reverse stakes
SMODS.Back{
    name = "Evil red deck",
    key = "evilred",
    atlas = "tobyaaasdecks",
    pos = {x = 3, y = 1},
    config = {evilred_backstakeorder = true},
    loc_txt = {
        name ="Evil Red deck",
        text = {
            "Stakes above white",
            "apply in reverse order",
            "{C:inactive,s:0.8}(vanilla stakes only)"
        }
    },
    loc_vars = function(self)
        return {vars = {}}
    end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.GAME.stake >= 2 then G.GAME.modifiers.enable_rentals_in_shop = true end
                if G.GAME.stake >= 3 then G.GAME.modifiers.enable_perishables_in_shop = true end 
                if G.GAME.stake < 7 then G.GAME.modifiers.scaling = 2 end --order here is important due to the comparisons
                if G.GAME.stake < 4 then G.GAME.modifiers.scaling = 1 end
                --blue stake works out to be in the middle anyway
                if G.GAME.stake < 6 then G.GAME.modifiers.enable_eternals_in_shop = false end
                --scaling would be already set to 3 after stake 7 anyway
                if G.GAME.stake < 8 then 
                    G.GAME.modifiers.no_blind_reward = G.GAME.modifiers.no_blind_reward or {}
                    G.GAME.modifiers.no_blind_reward.Small = nil
                end
                return true
            end
        }))
    end
}
-- [[patches]]
-- [patches.pattern]
-- target = "game.lua"
-- pattern = "if self.GAME.stake >= 8 then self.GAME.modifiers.enable_rentals_in_shop = true end"
-- position = "after"
-- payload = '''
-- if G.GAME.selected_back.effect.config.evilred_backstakeorder then
--     if self.GAME.stake >= 2 then self.GAME.modifiers.enable_rentals_in_shop = true end
--     if self.GAME.stake >= 3 then self.GAME.modifiers.enable_perishables_in_shop = true end 
--     if self.GAME.stake < 7 then self.GAME.modifiers.scaling = 2 end --order here is important due to the comparisons
--     if self.GAME.stake < 4 then self.GAME.modifiers.scaling = 1 end
--     --blue stake works out to be in the middle anyway
--     if self.GAME.stake < 6 then self.GAME.modifiers.enable_eternals_in_shop = false end
--     --scaling would be already set to 3 after stake 7 anyway
--     if self.GAME.stake < 8 then 
--         self.GAME.modifiers.no_blind_reward = self.GAME.modifiers.no_blind_reward or {}
--         self.GAME.modifiers.no_blind_reward.Small = nil
--     end
-- end
-- '''
-- match_indent = true

--blue deck
--credit: bred
--+hand size each hand, resets end of round
SMODS.Back{
    name = "Evil blue deck",
    key = "evilblue",
    atlas = "tobyaaasdecks",
    pos = {x = 1, y = 0},
    config = {evilbluehands = true, hand_size = -1},
    loc_txt = {
        name ="Evil blue deck",
        text = {
            "-1 hand size",
            "+1 hand size for each played hand",
            "resets at end of round",
            "{C:inactive,s:0.8}concept: bred"
        }
    },
    calculate = function(self, back, context)
        if context.after and context.main_eval then
            G.GAME.evilblue_hands_played = (G.GAME.evilblue_hands_played or 0) + 1
            G.hand:change_size(1)
        end
        if context.end_of_round and context.main_eval then
            G.hand:change_size(-(G.GAME.evilblue_hands_played or 0))
            G.GAME.evilblue_hands_played = 0
        end
    end,
    loc_vars = function(self)
        return {vars = {self.config.hand_size}}
    end
}

--yellow
--start with $0, coupon tag
SMODS.Back{
    name = "Evil yellow deck",
    key = "evilyellow",
    atlas = "tobyaaasdecks",
    pos = {x = 2, y = 0},
    config = {dollars = -4},
    loc_txt = {
        name ="Evil yellow deck",
        text = {
            "start run with {C:money}$0{}",
            "and a {C:attention,T:tag_coupon}coupon tag{}"
        }
    },
    loc_vars = function(self)
        return {vars = { self.config.dollars }}
    end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                add_tag(Tag('tag_coupon'))
                return true
            end
        }))
    end
}

--green
--Set $ to 8 on blind select
--(old ideas: extra pack, pricy rerolls? LESS packs, but more money; extra_discard_bonus = 2, extra_hand_bonus = 0)
SMODS.Back{
    name = "Evil green deck",
    key = "evilgreen",
    atlas = "tobyaaasdecks",
    pos = {x = 3, y = 0},
    config = {evilgreendollars = 8},
    loc_txt = {
        name ="Evil green deck",
        text = {
            "When Blind is selected,",
            "set money to {C:money}$#1#{}"
        }
    },
    calculate = function(self, back, context)
        if context.setting_blind then
            -- ease_dollars(self.config.evilgreendollars - G.GAME.dollars)
            local amount = self.config.evilgreendollars - (G.GAME.dollars + (G.GAME.dollar_buffer or 0))
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + amount
            G.E_MANAGER:add_event(Event({
                func = (function()
                    G.GAME.dollar_buffer = 0
                    return true
                end)
            }))
            return {
                dollars = amount
            }
        end
    end,
    loc_vars = function(self)
        return {vars = {self.config.evilgreendollars }}
    end
}

--black
-- :(

--magic
--credit: goose
--arcana packs always contain The Emperor
SMODS.Back{
    name = "Evil magic deck",
    key = "evilmagic",
    atlas = "tobyaaasdecks",
    pos = {x = 0, y = 1},
    config = {magicdeckemperor = true},
    loc_txt = {
        name ="Evil magic deck",
        text = {
            "{C:tarot}Arcana Packs{} always",
            "include {C:tarot,T:c_emperor}The Emperor{}",
            "{C:inactive,s:0.8}concept: goose!"
        }
    },
    loc_vars = function(self)
        return {vars = {}}
    end
}

--nebula
--credit: crispybag
--tarot tycoon. Arcana packs contain only The Fool
SMODS.Back{
    name = "Evil nebula deck",
    key = "evilnebula",
    atlas = "tobyaaasdecks",
    pos = {x = 1, y = 1},
    config = {nebuladeckfool = true, vouchers = {'v_tarot_merchant'}},
    loc_txt = {
        name ="Evil nebula deck",
        text = {
            "Start run with Tarot Merchant,",
            "{C:tarot}Arcana Packs{} {C:red}only{}",
            "include {C:tarot,T:c_fool}The Fool{}",
            "{C:inactive,s:0.8}concept: crispybag"
        }
    },
    loc_vars = function(self)
        return {vars = {}}
    end
}

--ghost
-- :(

--abandoned
--a random card of each rank is missing
SMODS.Back{
    name = "Evil abandoned deck",
    key = "evilabandoned",
    atlas = "tobyaaasdecks",
    pos = {x = 0, y = 0},
    config = {evilabandoned = true},
    loc_txt = {
        name ="Evil abandoned deck",
        text = {
            "Start run with a missing",
            "card of each rank"
        }
    }
}


-- if (G.GAME.selected_back.effect.config.evilabandoned) then
--     evilabandonedranks = {'A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K'}
--     for i = 1, 13 do
--         eabandonrank = evilabandonedranks[i]
--         for j = 1, 2 do
--             eabandoncard = {s = eabandonsuit, rn = eabandonrank, g = nil}
--             eabandonsuit = pseudorandom_element({'S','H','D','C'}, pseudoseed('evilabandoneddeck'))

--             G.playing_card = (G.playing_card and G.playing_card + 1) or 1
--             local _card = Card(G.deck.T.x, G.deck.T.y, G.CARD_W, G.CARD_H, G.P_CARDS[eabandoncard.s..'_'..eabandoncard.rn], G.P_CENTERS[eabandoncard.e or 'c_base'], {playing_card = G.playing_card})
            
--             G.deck:emplace(_card)
--             table.insert(G.playing_cards, _card)
--         end
--     end
-- end

--checkered
--credit: zucchini
--extra 13 wild cards
SMODS.Back{
    name = "Evil checkered deck",
    key = "evilcheckered",
    atlas = "tobyaaasdecks",
    pos = {x = 4, y = 1},
    config = {checkerdeckwilds = true},
    loc_txt = {
        name ="Evil checkered deck",
        text = {
            "Start run with 13",
            "additional wild cards",
            "{C:inactive,s:0.8}concept:ABuffZucchini"
        }
    }
}

--zodiac
--overstock but expensive rerolls
SMODS.Back{
    name = "Evil zodiac deck",
    key = "evilzodiac",
    atlas = "tobyaaasdecks",
    pos = {x = 0, y = 2},
    config = {
        -- vouchers = {'v_hone', 'v_glow_up', 'v_magic_trick', 'v_illusion', 
        -- 'v_planet_merchant', --'v_planet_tycoon', 
        -- 'v_tarot_merchant', --'v_tarot_tycoon',
        -- },
        vouchers = {'v_overstock_norm'}, reroll_discount = -2 --, 'v_overstock_plus'
    },
    loc_txt = {
        name ="Evil zodiac deck",
        text = {
            -- "start run with the Illusion,",
            -- "Planet Merchant, Tarot Merchant,",
            -- "and Glow Up vouchers",
            -- "{C:inactive,s:0.8}concept:bred"
            "start run with the",
            "Overstock voucher",
            "rerolls cost $2 more"
        }
    },
    loc_vars = function(self)
        return {vars = {}}
    end
}

--painted
-- -1 joker + Trance
SMODS.Back{
    name = "Evil painted deck",
    key = "evilpainted",
    atlas = "tobyaaasdecks",
    pos = {x = 1, y = 2},
    config = {joker_slot = -1, consumables = {'c_trance'}
    },
    loc_txt = {
        name ="Evil painted deck",
        text = {
            "{C:red}-1{} joker slot",
            "Start run with a Trance card"
        }
    },
    loc_vars = function(self)
        return {vars = {self.config.hand_size, self.config.joker_slot}}
    end
}

--anaglyph
--reroll tags w (currently voucher)
SMODS.Back{
    name = "Evil anaglyph deck",
    key = "evilanaglyph",
    atlas = "tobyaaasdecks",
    pos = {x = 2, y = 2},
    config = {evilanaglyphtags = true },
    loc_txt = {
        name ="Evil anaglyph deck",
        text = {
            "Shop rerolls also",--perhaps, first sold item? voucher bought? something else?
            "reroll the ante's {C:attention}Tags{}"
        }
    },
    loc_vars = function(self)
        return {vars = {}}
    end,
    calculate = function(self, back, context)
        
        --context.buying_card and context.card.ability.set == 'Voucher' and
        if context.reroll_shop and G.GAME.blind_on_deck ~= 'Boss' then
            G.GAME.round_resets.blind_tags.Big = get_next_tag_key()--weirdly the blind on deck thing doesn't really work?
            if G.GAME.blind_on_deck ~= 'Big' then
                G.GAME.round_resets.blind_tags.Small = get_next_tag_key()
            end
            --if G.GAME.last_blind.boss
        end
        --if context.reroll_shop then --and G.GAME.tobyaaasdecks_evilanaglyphrerollused == false
            --G.GAME.tobyaaasdecks_evilanaglyphrerollused = true;
        --end
        --if context == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
        --    G.GAME.tobyaaasdecks_evilanaglyphrerollused = false;
        --end
        --TODO: make one use
    end,
}

--plasma & erratic
-- lmaoooo no


--find "after cash out":
--add an event that gives a booster pack
--before doing so, though, add a game variable
--in the booster pack opening code:
--if that game variable is true, disallow editions, seals
--in the button code, disallow skips if true
--find the code that runs when the player takes the second card; in there, set that variable to false


------------------------------------------------------------------------------------------------------------------------------------------------------------------
--edits to existing functions
------------------------------------------------------------------------------------------------------------------------------------------------------------------


--change hand size midround depending on deck
--blue, painted
-- local updateRef = CardArea.update
-- function CardArea.update(self, dt)
    
--     if G.GAME.selected_back.effect.config.evilbluehands and self == G.hand then
--         self.config.last_poll_size = self.config.last_poll_size or 0
--         if math.floor(G.GAME.current_round.hands_played) ~= self.config.last_poll_size then
--              self:change_size(math.floor(G.GAME.current_round.hands_played - self.config.last_poll_size))
--              self.config.last_poll_size = math.floor(G.GAME.current_round.hands_played)
--         end
--     end
--     if G.GAME.selected_back.effect.config.evilpainthands and self == G.hand then
--         self.config.last_poll_size = self.config.last_poll_size or 0
--         local slotsFilled = math.floor( #G.jokers.cards / 2)

--         if math.floor(slotsFilled) ~= self.config.last_poll_size then
--              self:change_size(math.floor(self.config.last_poll_size - slotsFilled))
--              self.config.last_poll_size = math.floor(slotsFilled)
--         end
--     end
--     updateRef(self, dt)
-- end



--mess with booster contents (magic, nebula)
SMODS.Booster:take_ownership_by_kind('Arcana', {
    create_card = function(self, card, i)
        --magic deck
        if G.GAME.selected_back.effect.config.magicdeckemperor and i == 1 then
            return {set = "Tarot", area = G.pack_cards, skip_materialize = true, soulable = true, key = 'c_emperor', key_append='ar1'}
            --nebula deck
        elseif G.GAME.selected_back.effect.config.nebuladeckfool then
            return {set = "Tarot", area = G.pack_cards, skip_materialize = true, soulable = true, key = 'c_fool', key_append='ar1'}
        else 
            return {set = "Tarot", area = G.pack_cards, skip_materialize = true, soulable = true, key_append='ar1'}
        end
    end,
}, true)