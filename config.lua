Config = {}
Config.MaxCharacters = 6
Config.debugEnabled = true

Config.NEW_CHARACTER = {
    coords = vector3(917.6935, 55.3960, 110.7011),
    heading = 75.2962,
    animation = {dict = "amb@world_human_leaning@male@wall@back@foot_up@idle_a", anim = "idle_a"}
}

Config.CHARACTER_CUSTOMIZATION = {
    coords = vector3(913.8629, 58.7251, 111.6612),
    heading = 55.2679,
}

Config.CHARACTER_ROOM = {
    coords = vector3(915.4648, 51.8233, 114.0158), -- Starting camera position
    heading = 250.6621, -- Adjusted heading to face the correct way
    
    -- Add positions table for character peds
    positions = {
        {
            coords = vector3(908.0535, 53.9700, 110.7013),
            heading = 228.9638,
            animation = {dict = "rcmjosh1", anim = "idle"},
            camera = {
                positionalOffset = vector3(0.7, -1.0, 0.25), -- 0.7, -1.0, 0.5
                rotationalOffset = vector3(0.0, 0.0, 0.25),
                fov = 70.0
            }
        },
        {
            coords = vector3(907.7285, 52.9016, 110.7013),
            heading = 266.7092,
            animation = {dict = "amb@world_human_stand_guard@male@idle_a", anim = "idle_a"},
            camera = {
                positionalOffset = vector3(1.2, 0.0, 0.25), -- 1.2, 0.0, 0.5
                rotationalOffset = vector3(0.0, 0.0, 0.25),
                fov = 60.0
            }
        },
        {
            coords = vector3(911.3921, 53.7663, 110.75), -- 911.3125, 53.7031, 111.6964, 126.8319
            heading = 125.1907,
            animation = {dict = "anim@amb@business@cfm@cfm_machine_no_work@", anim = "hanging_out_operator"},
            camera = {
                positionalOffset = vector3(-0.5, -1.0, 0.0),    -- -0.5, -1.0, -0.25
                rotationalOffset = vector3(0.0, 0.0, -0.25),
                fov = 60.0
            }
        },
        {
            coords = vector3(910.5148, 54.6012, 111.1265), -- 909.7689, 54.4071, 111.7011, 195.9286
            heading = 165.6402,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"},
            camera = {
                positionalOffset = vector3(-0.5, -1.0, -0.25),
                rotationalOffset = vector3(0.0, 0.0, -0.25),
                fov = 60.0
            }
        },
        {
            coords = vector3(910.5527, 51.6711, 110.6), -- 910.5839, 51.4669, 111.7007, 12.3132
            heading = 26.4501,
            animation = {dict = "timetable@reunited@ig_10", anim = "base_amanda"},
            camera = {
                positionalOffset = vector3(-1.0, 0.5, 0.0),
                rotationalOffset = vector3(0.0, -0.5, -0.25),
                fov = 60.0
            }
        },
        {
            coords = vector3(909.4823, 51.3214, 110.6573), -- 909.0135, 51.6922, 111.7010, 339.5112
            heading = 344.3992,
            animation = {dict = "anim@heists@fleeca_bank@hostages@intro", anim = "intro_loop_ped_a"},
            camera = {
                positionalOffset = vector3(0.75, 1.0, 0.0),
                rotationalOffset = vector3(0.0, -0.5, -0.25),
                fov = 60.0
            }
        },
        
        -- {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        
    },
    
    -- Camera positions
    cameras = {
        overview = {
            coords = vector3(915.4648, 51.8233, 114.0158),
            point = vector3(910.4648, 51.8233, 112.1264), -- Adjusted to point at the center of the sitting area
            fov = 60.0
        },
        character = {
            offset = vector3(1.0, 1.0, 0.5),
            fov = 60.0
        },
        newCharacter = {
            offset = vector3(1.0, -1.0, 0.25),
            fov = 80.0
        }
    }
}