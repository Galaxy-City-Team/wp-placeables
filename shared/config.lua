Config = {}

Config.Framework = 'esx' -- supports 'qb' or 'esx'
Config.Notify = 'esx' -- supports 'qb', 'esx', 'ox' (if using ox enable @ox_lib/init.lua in the manifest)
Config.Target = 'qb' -- only 'qb' for now

Config.ItemPlacementModeRadius = 10.0 -- Object can only be placed within this radius of the player

-- These are necessary so people can't place props far away
Config.minZOffset = -2.0 -- The min z offset for placing objects
Config.maxZOffset = 2.0 -- The max z offset for placing objects

-- Creates a deep copy of the table
-- This is necessary for getting around luas pass by reference of tables
local function deepcopy(orig) -- modified the deep copy function from http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if not orig.canOpen or orig.canOpen() then
            local toRemove = {}
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                if type(orig_value) == 'table' then
                    if not orig_value.canOpen or orig_value.canOpen() then
                        copy[deepcopy(orig_key)] = deepcopy(orig_value)
                    else
                        toRemove[orig_key] = true
                    end
                else
                    copy[deepcopy(orig_key)] = deepcopy(orig_value)
                end
            end
            for i=1, #toRemove do table.remove(copy, i) --[[ Using this to make sure all indexes get re-indexed and no empty spaces are in the radialmenu ]] end
            if copy and next(copy) then setmetatable(copy, deepcopy(getmetatable(orig))) end
        end
    elseif orig_type ~= 'function' then
        copy = orig
    end
    return copy
end

-- Helper function to combine default options with custom target options for items
---@param targetOptions: The default target options for the item (example pushTargetOptions for push only objects and pushAndSitTargetOptions for push and sit objects)
---@param animationPushOptions: Optional - The custom animation options for pushing the object (modifying offsets, rotations, animations)
---@param animationSitOptions: Optional - The custom animation options for sitting on the object (modifying offsets, rotations, animations)
---@param otherOptions: Optional - Any other custom target options you want to add to the item
local function setCustomTargetOptions(targetOptions, animationPushOptions, animationSitOptions, otherOptions)
    local customTargetOptions = deepcopy(targetOptions)

    if animationPushOptions then
        customTargetOptions[1].animationPushOptions = animationPushOptions
    end

    if animationSitOptions then
        customTargetOptions[2].animationSitOptions = animationSitOptions
    end

    if otherOptions then
        for i = 1, #otherOptions do
            customTargetOptions[#customTargetOptions + 1] = otherOptions[i]
        end
    end

    return customTargetOptions
end

-- Default target options

local pushAndSitTargetOptions = {
    {
        event = "wp-placeables:client:pushObject",
        icon = "fas fa-shopping-cart",
        label = "Gegenstand schieben",
        animationPushOptions = {
            offset = {x =  -0.4, y = -1.7, z = -0.3},
            rotation = {x = 0.0, y = 0.0, z = 180.0},
            animationDict = "missfinale_c2ig_11",
            animationName = "pushcar_offcliff_f",
        }
    },
    {
        event = "wp-placeables:client:sitOnObject",
        icon = "fas fa-chair",
        label = "Sich hinsetzen",
        animationSitOptions = {
            offset = {x = 0.0, y = 0.15, z = 0.85},
            rotation = {x = 0.0, y = 10.0, z = 175.0},
            animationDict = "anim@amb@business@bgen@bgen_no_work@",
            animationName = "sit_phone_phoneputdown_idle_nowork",
        }
    },
}

local pushTargetOptions = {
    {
        event = "wp-placeables:client:pushObject",
        icon = "fas fa-shopping-cart",
        label = "Schiebewagen",
        animationPushOptions = {
            offset = {x =  -0.4, y = -1.7, z = -0.3},
            rotation = {x = 0.0, y = 0.0, z = 180.0},
            animationDict = "missfinale_c2ig_11",
            animationName = "pushcar_offcliff_f",
        }
    },
}

-- Define custom target options here for addon items

local chairCustomTargetOptions = {
    {
        event = "qb-sit:sit",
        icon = "fas fa-chair",
        label = "Hinsetzen",
    },
}

-- Uncomment this line if you are using wp-yogamats
-- local yogaCustomTargetOptions = {
--     {
--         event = "wp-yogamats:client:useYogaMat",
--         icon = "fas fa-pray",
--         label = "Do yoga",
--     },
-- }

-- Uncomment this line if you are using wp-printer
local printerCustomTargetOptions = {
    {
        event = "wp-printer:client:UsePrinter",
        icon = "fas fa-print",
        label = "Drucker verwenden",
    },
}

-- Add the props you want to be placeable here
-- Every prop will have the "pickup" target option added by default (to override use customPickupEvent)
-- REQUIRED FIELDS:
---@param item: The item name as defined in your items.lua
---@param label: The label to be used for this item (displayed in the progress bar)
---@param model: The prop model to be used for this item
---@param isFrozen: Whether or not the prop should be frozen in place when placed
--- OPTIONAL FIELDS:
---@param customTargetOptions: Custom target options for this item, if it should do more than just pickup
---@param customPickupEvent: If you want to override the default pickup event, set this to the event you want to be called when the "pickup" target option is used
---@param shouldUseItemNameState: Only need to set this to true if you want to have multiple items use the same prop model. Otherwise you do not need to define it
Config.PlaceableProps = {
    -- Constructions props
    {item = "roadworkbarrier", label = "Strasse Gespeert Barriere", model = "prop_barrier_work04a", isFrozen = true},
    {item = "roadclosedbarrier", label = "Strasse Geschlossen Barriere", model = "xm3_prop_xm3_road_barrier_01a", isFrozen = true},
    {item = "constructionbarrier", label = "Ausklappbare Barrieren", model = "prop_barrier_work01a", isFrozen = false},
    {item = "constructionbarrier2", label = "Konstruktions Barrier", model = "prop_barrier_work06a", isFrozen = true},
    {item = "constructionbarrier3", label = "Konstruktions Barrier", model = "prop_mp_barrier_02b", isFrozen = true},
    {item = "roadconebig", label = "Grosser Strassenkegel", model = "prop_barrier_wat_03a", isFrozen = false},
    {item = "roadcone", label = "Strassenkegel", model = "prop_roadcone01a", isFrozen = false},
    {item = "roadpole", label = "Straßenmast", model = "prop_roadpole_01a", isFrozen = false},
    {item = "worklight", label = "Arbeitslampe", model = "prop_worklight_01a", isFrozen = false},
    {item = "worklight2", label = "Arbeitslampe", model = "prop_worklight_04b", isFrozen = false},
    {item = "worklight3", label = "Arbeitslampe", model = "prop_worklight_02a", isFrozen = false},
    {item = "constructiongenerator", label = "Baugenerator", model = "prop_generator_03b", isFrozen = true},
    {item = "trafficdevice", label = "Verkehrsgerät (Links)", model = "prop_trafficdiv_01", isFrozen = true},
    {item = "trafficdevice2", label = "Verkehrsgerät (Rechts)", model = "prop_trafficdiv_02", isFrozen = true},
    {item = "meshfence1", label = "Maschendrahtzaun (Klein)", model = "prop_fnc_omesh_01a", isFrozen = true},
    {item = "meshfence2", label = "Maschendrahtzaun (Mittel)", model = "prop_fnc_omesh_02a", isFrozen = true},
    {item = "meshfence3", label = "Maschendrahtzaun (Gross)", model = "prop_fnc_omesh_03a", isFrozen = true},
    {item = "waterbarrel", label = "Wasserfass", model = "prop_barrier_wat_04a", isFrozen = false},

    -- Camping + Hobo props
    {item = "tent", label = "Altes Zelt", model = "prop_skid_tent_03", isFrozen = true},
    {item = "tent2", label = "Zelt", model = "prop_skid_tent_01", isFrozen = true},
    {item = "tent3", label = "Grosses Zelt", model = "ba_prop_battle_tent_02", isFrozen = true},
    {item = "hobostove", label = "Hobo-Herd", model = "prop_hobo_stove_01", isFrozen = true},
    {item = "campfire", label = "Lagerfeuer", model = "prop_beach_fire", isFrozen = true},
    {item = "hobomattress", label = "Hobo-Matratze", model = "prop_rub_matress_01", isFrozen = true},
    {item = "hoboshelter", label = "Hobo-Unterkunft", model = "prop_homeles_shelter_01", isFrozen = true},
    {item = "sleepingbag", label = "Schlafsack", model = "prop_skid_sleepbag_1", isFrozen = true},
    {item = "canopy1", label = "Überdachung (Grün)", model = "prop_gazebo_01", isFrozen = true},
    {item = "canopy2", label = "Überdachung (Blau)", model = "prop_gazebo_02", isFrozen = true},
    {item = "canopy3", label = "Überdachung (Weiss)", model = "prop_gazebo_03", isFrozen = true},
    {item = "cot", label = "Kinderbett", model = "gr_prop_gr_campbed_01", isFrozen = true},

    -- Triathlon props
    {item = "tristarttable", label = "Triathlon-Starttabelle", model = "prop_tri_table_01", isFrozen = true},
    {item = "tristartbanner", label = "Triathlon-Startbanner", model = "prop_tri_start_banner", isFrozen = true},
    {item = "trifinishbanner", label = "Triathlon-Zielbanner", model = "prop_tri_finish_banner", isFrozen = true},

    -- Table props
    {item = "plastictable", label = "Plastiktisch", model = "prop_ven_market_table1", isFrozen = true},
    {item = "plastictable2", label = "Plastiktisch", model = "prop_table_03", isFrozen = true},
    {item = "woodtable", label = "Kleiner Holztisch", model = "prop_rub_table_01", isFrozen = true},
    {item = "woodtable2", label = "Holztisch", model = "prop_rub_table_02", isFrozen = true},

    -- Beach props
    {item = "beachtowel", label = "Badetuch", model = "prop_cs_beachtowel_01", isFrozen = true},
    {item = "beachumbrella", label = "Sonnenschirm", model = "prop_parasol_04b", isFrozen = true},
    {item = "beachumbrella2", label = "Sonnenschirm", model = "prop_beach_parasol_02", isFrozen = true},
    {item = "beachumbrella3", label = "Sonnenschirm", model = "prop_beach_parasol_06", isFrozen = true},
    {item = "beachumbrella4", label = "Sonnenschirm", model = "prop_beach_parasol_10", isFrozen = true},
    {item = "beachball", label = "Sonnenschirm", model = "prop_beachball_02", isFrozen = false},

    -- Ramp props
    {item = "ramp1", label = "Holzrampe (Gradual)", model = "prop_mp_ramp_01", isFrozen = true},
    {item = "ramp2", label = "Holzrampe (Moderate)", model = "prop_mp_ramp_02", isFrozen = true},
    {item = "ramp3", label = "Holzrampe (Steil)", model = "prop_mp_ramp_03", isFrozen = true},
    {item = "ramp4", label = "Holzrampe (Gross)", model = "xs_prop_arena_pipe_ramp_01a", isFrozen = true},
    {item = "ramp5", label = "Anhängerrampe aus Metall", model = "xs_prop_x18_flatbed_ramp", isFrozen = true},
    {item = "skateramp", label = "Skate-Rampe", model = "prop_skate_flatramp", isFrozen = true},
    {item = "stuntramp1", label = "Stunt-Rampe S", model = "stt_prop_ramp_adj_flip_s", isFrozen = true},
    {item = "stuntramp2", label = "Stunt-Rampe M", model = "stt_prop_ramp_adj_flip_m", isFrozen = true},
    {item = "stuntramp3", label = "Stunt-Rampe L", model = "stt_prop_ramp_jump_l", isFrozen = true},
    {item = "stuntramp4", label = "Stunt-Rampe XL", model = "stt_prop_ramp_jump_xl", isFrozen = true},
    {item = "stuntramp5", label = "Stunt-Rampe XXL", model = "stt_prop_ramp_jump_xxl", isFrozen = true},
    {item = "stuntloop1", label = "Stunt-Halblooping", model = "stt_prop_ramp_adj_hloop", isFrozen = true},
    {item = "stuntloop2", label = "Stunt-Looping", model = "stt_prop_ramp_adj_loop", isFrozen = true},
    {item = "stuntloop3", label = "Stunt-Spirale", model = "stt_prop_ramp_spiral_s", isFrozen = true},

    -- EMS/Hospital props
    {item = "medbag", label = "Medizinische Tasche", model = "xm_prop_x17_bag_med_01a", isFrozen = true},
    {item = "examlight", label = "Prüfungslicht", model = "v_med_examlight", isFrozen = true},
    {item = "hazardbin", label = "Gefahrenbehälter", model = "v_med_medwastebin", isFrozen = true},
    {item = "microscope", label = "Mikroscop", model = "v_med_microscope", isFrozen = true},
    {item = "oscillator", label = "Oszillator", model = "v_med_oscillator3", isFrozen = true},
    {item = "medmachine", label = "Medizinische Maschine", model = "v_med_oscillator4", isFrozen = true},
    {item = "bodybag", label = "Leichensack", model = "xm_prop_body_bag", isFrozen = true},

    -- Chairs
    {item = "camp_chair_green", label = "Campingstuhl (Grün)", model = "prop_skid_chair_01", isFrozen = true, customTargetOptions = chairCustomTargetOptions},
    {item = "camp_chair_blue", label = "Campingstuhl (Blau)", model = "prop_skid_chair_02", isFrozen = true, customTargetOptions = chairCustomTargetOptions},
    {item = "camp_chair_plaid", label = "Campingstuhl (Plaid)", model = "prop_skid_chair_03", isFrozen = true, customTargetOptions = chairCustomTargetOptions},
    {item = "plastic_chair", label = "Plastik Stuhl", model = "prop_chair_08", isFrozen = true, customTargetOptions = chairCustomTargetOptions},
    {item = "folding_chair", label = "Klappstuhl", model = "xm3_prop_xm3_folding_chair_01a", isFrozen = true, customTargetOptions = chairCustomTargetOptions},

    -- Misc props
    {item = "greenscreen", label = "Greenscreen", model = "prop_ld_greenscreen_01", isFrozen = true},
    {item = "ropebarrier", label = "Seilbarriere", model = "vw_prop_vw_barrier_rope_01a", isFrozen = false},
    {item = "largesoccerball", label = "Grosser Fussball", model = "stt_prop_stunt_soccer_ball", isFrozen = false},
    {item = "soccerball", label = "Fussball", model = "p_ld_soc_ball_01", isFrozen = false},
    {item = "stepladder", label = "Trittleiter", model = "v_med_cor_stepladder", isFrozen = true},
    {item = "sexdoll", label = "Sexpuppe", model = "prop_defilied_ragdoll_01", isFrozen = true},

    -- Pushable items
    {item = "shoppingcart1", label = "Schubkarre (Leer)", model = "prop_rub_trolley01a", isFrozen = false, customTargetOptions = pushAndSitTargetOptions},
    {item = "shoppingcart2", label = "Schubkarre (Voll)", model = "prop_skid_trolley_2", isFrozen = false, customTargetOptions = pushTargetOptions},
    {item = "shoppingcart3", label = "Schubkarre (Leer)", model = "prop_rub_trolley02a", isFrozen = false, customTargetOptions = pushAndSitTargetOptions},
    {item = "shoppingcart4", label = "Warenkorb (Voll)", model = "prop_skid_trolley_1", isFrozen = false, customTargetOptions = pushTargetOptions},
    {item = "wheelbarrow", label = "Schubkarre", model = "prop_wheelbarrow01a", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushAndSitTargetOptions, {
                offset = {x =  -0.4, y = -1.8, z = -0.6},
                rotation = {x = 0.0, y = 20.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }, {
                offset = {x = -0.25, y = 0.0, z = 1.4},
                rotation = {x = 13.0, y = 0.0, z = 255.0},
                animationDict = "anim@amb@business@bgen@bgen_no_work@",
                animationName = "sit_phone_phoneputdown_idle_nowork",
            }
        )
    },
    {item = "warehousetrolly1", label = "Lagerwagen (Leer)", model = "hei_prop_hei_warehousetrolly_02", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushAndSitTargetOptions, {
                offset = {x =  -0.4, y = -1.5, z = -0.9},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }, {
                offset = {x = -0.15, y = 0.15, z = 1.25},
                rotation = {x = 0.0, y = 10.0, z = 175.0},
                animationDict = "anim@amb@business@bgen@bgen_no_work@",
                animationName = "sit_phone_phoneputdown_idle_nowork",
            }
        )
    },
    {item = "warehousetrolly2", label = "Lagerwagen (voll)", model = "prop_flattruck_01d", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.5, z = -0.9},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "roomtrolly", label = "Zimmerwagen", model = "ch_prop_ch_room_trolly_01a", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.8},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "janitorcart1", label = "Hausmeisterwagen", model = "prop_cleaning_trolly", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.3, y = -1.6, z = -0.9},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "janitorcart2", label = "Hausmeisterwagen", model = "ch_prop_ch_trolly_01a", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.3, y = -1.75, z = -0.3},
                rotation = {x = 0.0, y = 0.0, z = 270.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "mopbucket", label = "Putzeimer", model = "prop_tool_mopbucket", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.3, y = -1.9, z = -0.8},
                rotation = {x = 0.0, y = 0.0, z = 270.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "metalcart", label = "Metallwagen", model = "prop_gold_trolly", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.35},
                rotation = {x = 0.0, y = 0.0, z = 270.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "teacart", label = "Teewagen", model = "prop_tea_trolly", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.4},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "drinkcart", label = "Getränkewagen", model = "h4_int_04_drink_cart", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.4},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "handtruck1", label = "Sackkarre", model = "prop_sacktruck_02a", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.4, z = -0.8},
                rotation = {x = -35.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "handtruck2", label = "Sackkarre (Kisten)", model = "prop_sacktruck_02b", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.4, z = -0.75},
                rotation = {x = -35.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "trashbin", label = "Mülleimer", model = "prop_cs_bin_01_skinned", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushAndSitTargetOptions, {
                offset = {x =  -0.4, y = -1.62, z = -0.8},
                rotation = {x = -15.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }, {
                offset = {x = 0.02, y = 0.15, z = 1.25},
                rotation = {x = 0.0, y = 0.0, z = 175.0},
                animationDict = "anim@model_kylie_insta",
                animationName = "kylie_insta_clip",
            }
        )
    },
    {item = "lawnmower", label = "Rasenmäher", model = "prop_lawnmower_01", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.43, y = -1.6, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "toolchest", label = "Werkzeugkasten", model = "prop_toolchest_03", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.95, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "carjack", label = "Wagenheber", model = "prop_carjack", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.75, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "hospitalbedtable", label = "Krankenhaus-Nachttisch", model = "v_med_bedtable", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.7, z = -0.35},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "medtable", label = "Medizinischer Tisch", model = "v_med_trolley2", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.75, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },

    -- ADDON ITEMS

    -- Yogamats
    -- Uncomment this line if you are using wp-yogamats
    -- {item = "yogamat_blue", label = "Yoga mat (Blue)", model = "prop_yoga_mat_01", isFrozen = true, customTargetOptions = yogaCustomTargetOptions},
    -- {item = "yogamat_black", label = "Yoga mat (Black)", model = "prop_yoga_mat_02", isFrozen = true, customTargetOptions = yogaCustomTargetOptions},
    -- {item = "yogamat_red", label = "Yoga mat (Red)", model = "prop_yoga_mat_03", isFrozen = true, customTargetOptions = yogaCustomTargetOptions},

    -- Printers
    -- Uncomment this line if you are using wp-printer
     {item = "printer", label = "Drucker", model = "prop_printer_01", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
     {item = "printer2", label = "Drucker", model = "prop_printer_02", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
     {item = "printer3", label = "Drucker", model = "v_res_printer", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
     {item = "printer4", label = "Drucker", model = "v_ret_gc_print", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
     {item = "photocopier", label = "Kopiergerät", model = "v_med_cor_photocopy", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
    
    -- ADD YOUR CUSTOM PROPS HERE
}
