{ inputs, ... }:{ 
  programs.firefox = {
    enable = true;
    profiles.bruh = {
      bookmarks = [
        {
          # name = "Singles";
          toolbar = true;
          bookmarks = [
            {
              name = "Blackboard";
              url = "https://elearn.mu-varna.bg/";
            }
            {
              name = "Webstudent";
              url = "https://webstudent.mu-varna.bg";
            }
          ];
        }
        { 
          # name = "Folders";
          toolbar = true;
          bookmarks = [
            { 
              name = "Study";
              bookmarks = [
                {
                  name = "4 курс";
                  url = "https://drive.google.com/drive/folders/1RBVr6c4sohajfoT4UCsf2Vz51Z9a6FLp";
                }
                {
                  name = "5 курс";
                  url = "https://drive.google.com/drive/folders/1gwV_0arFMICVYtxqF9_G_0oXXP7dxNnT";
                }
                {
                  name = "6 курс";
                  url = "https://drive.google.com/drive/folders/1S_hfoHuqoWtIkH9kG7q6iJ9-zUsAIwvu";
                }
                {
                  name = "Full Mega";
                  url = "https://mega.nz/folder/mY0nSaBQ#uGTfgaVvlcVDQ9l2u6iFJw";
                }
              ];
            } 
          ];
        }
      ];
      settings = {
        "browser.privatebrowsing.autostart" = true;
        "browser.translations.automaticallyPopup" =  false;
      };
      extraConfig = ''
	      user_pref("extensions.autoDisableScopes", 0);
	      user_pref("extensions.enabledScopes", 15);
      '';
      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        keepassxc-browser
        ublock-origin
        vimium-c
      ];
    };
  };
}
