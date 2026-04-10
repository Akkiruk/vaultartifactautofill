package com.vaultartifactautofill;

import com.vaultartifactautofill.config.ModConfig;
import net.minecraftforge.fml.ModLoadingContext;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.config.ModConfig.Type;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@Mod(VaultArtifactAutofillMod.MOD_ID)
public class VaultArtifactAutofillMod {
    public static final String MOD_ID = "vaultartifactautofill";
    public static final Logger LOGGER = LogManager.getLogger(MOD_ID);

    public VaultArtifactAutofillMod() {
        LOGGER.info("Initializing Vault Artifact Autofill");
        ModLoadingContext.get().registerConfig(Type.CLIENT, ModConfig.CLIENT_SPEC);
    }
}
