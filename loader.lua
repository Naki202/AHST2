-- ✅ AHS T3 Loader Script -- Gọi lần lượt 3 module: core, esp, ui từ GitHub

local base = "https://raw.githubusercontent.com/Naki202/AHST2/main/modules/"

-- Load core (mã hóa bằng MoonsecV3) local success_core, err_core = pcall(function() loadstring(game:HttpGet(base .. "core.lua"))() end) if not success_core then warn("[AHS-LOADER] Lỗi tải core.lua:", err_core) end

-- Load ESP local success_esp, err_esp = pcall(function() loadstring(game:HttpGet(base .. "esp.lua"))() end) if not success_esp then warn("[AHS-LOADER] Lỗi tải esp.lua:", err_esp) end

-- Load UI local success_ui, err_ui = pcall(function() loadstring(game:HttpGet(base .. "ui.lua"))() end) if not success_ui then warn("[AHS-LOADER] Lỗi tải ui.lua:", err_ui) end

