package com.vaultartifactautofill;

import com.vaultartifactautofill.config.ModConfig;
import net.minecraftforge.fml.ModLoadingContext;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.config.ModConfig.Type;

@Mod(VaultArtifactAutofillMod.MOD_ID)
public class VaultArtifactAutofillMod {
    public static final String MOD_ID = "vaultartifactautofill";

    public VaultArtifactAutofillMod() {
        ModLoadingContext.get().registerConfig(Type.CLIENT, ModConfig.CLIENT_SPEC);
    }
}
