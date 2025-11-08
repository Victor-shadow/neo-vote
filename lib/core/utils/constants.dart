class AppConstants {
    static const String appName = "NeoVote";
    static const String solanaProgramId = 'BZJ5VsduzyrzeoiN2djRcbCKKip3t8WNmhF7ZEhoLMuz';
    static const String apiBaseUrl = 'https://api.neovote.com';
    static const String solanaRpcUrl = "https://api.devnet.solana.com";
    static const String authTokenKey = "AUTH_TOKEN";
    static const String themePreferenceKey = "THEME_PREFERENCE";
    static const Duration apiTimeout = Duration(seconds: 6000);
    static const voteSessionTimeoutSeconds = 300; //5 minutes
}