Config = {}
Config.MaxCharacters = 6
Config.debugEnabled = true

Config.NEW_CHARACTER = {
    coords = vector3(918.3449, 58.7333, 111.7011),
    heading = 88.5904,
    animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
}

Config.CHARACTER_ROOM = {
    coords = vector3(915.4648, 51.8233, 114.0158), -- Starting camera position
    heading = 250.6621, -- Adjusted heading to face the correct way
    
    -- Add positions table for character peds
    positions = {
        {
            coords = vector3(911.6921, 53.7663, 111.1264),
            heading = 125.1907,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(910.8527, 51.2711, 111.1264),
            heading = 26.4501,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(909.4823, 51.0214, 111.1273),
            heading = 344.3992,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(910.5148, 54.6012, 111.1265),
            heading = 165.6402,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(906.8790, 53.8894, 111.2616),
            heading = 242.5208,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(912.2040, 54.1265, 111.6119),
            heading = 304.3833,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        }
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
            fov = 40.0
        }
    }
}