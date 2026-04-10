package com.vaultartifactautofill.config;

import net.minecraftforge.common.ForgeConfigSpec;

public class ModConfig {
    public static final ForgeConfigSpec CLIENT_SPEC;
    public static final ForgeConfigSpec.BooleanValue ARTIFACT_PROJECTOR_AUTOFILL_ENABLED;

    static {
        ForgeConfigSpec.Builder clientBuilder = new ForgeConfigSpec.Builder();

        clientBuilder.comment("Client-side helpers").push("artifactProjector");
        ARTIFACT_PROJECTOR_AUTOFILL_ENABLED = clientBuilder
                .comment("When enabled, right-clicking your own incomplete Vault artifact projector will batch-place any matching artifacts from your inventory using normal client interactions.")
                .define("autofillEnabled", true);
        clientBuilder.pop();

        CLIENT_SPEC = clientBuilder.build();
    }
}
