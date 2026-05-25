# Firefox declarative configuration
{ pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;

    profiles.default = {
      isDefault = true;

      # Extensions
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        return-youtube-dislikes
        control-panel-for-twitter
        docsafterdark
      ];

      # Dark mode and other settings
      settings = {
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        "layout.css.prefers-color-scheme.content-override" = 0;
      };

      # Bookmarks
      bookmarks = {
        force = true;
        settings = [
          {
            name = "Toolbar";
            toolbar = true;
            bookmarks = [
              { name = "iCloud"; url = "https://www.icloud.com/mail"; }
              { name = "Gmail"; url = "https://mail.google.com/mail/u/0/#inbox"; }
              { name = "Personal"; url = "https://mail.mangan.com/"; }
              { name = "Google Drive"; url = "https://drive.google.com/drive/my-drive"; }
              { name = "YouTube"; url = "https://www.youtube.com/"; }
              { name = "Home"; url = "https://x.com/home"; }
              {
                name = "Utilities";
                bookmarks = [
                  { name = "TinyURL"; url = "https://tinyurl.com/"; }
                  { name = "Internet speed test"; url = "https://fast.com/#"; }
                  { name = "Feedly"; url = "https://feedly.com/i/my"; }
                  { name = "Wikipedia"; url = "https://www.wikipedia.org/"; }
                  { name = "Thesaurus"; url = "https://www.thesaurus.com/"; }
                  { name = "YT MP3"; url = "https://ytmp3.cc/en13/"; }
                  { name = "Messenger"; url = "https://www.messenger.com/t/eryn.lelong.3"; }
                  { name = "Newegg"; url = "https://www.newegg.com/"; }
                  { name = "Steam"; url = "https://store.steampowered.com/about/"; }
                  { name = "Spotify"; url = "http://play.spotify.com/"; }
                  { name = "MEE6"; url = "https://mee6.xyz/dashboard/696679001539870761"; }
                  { name = "SankeyMATIC"; url = "http://sankeymatic.com/build/"; }
                  { name = "Amazon"; url = "https://www.amazon.co.uk/"; }
                  { name = "Quizziz"; url = "https://quizizz.com/admin/quiz/5672c216098347654b78c0f1/christmas"; }
                  { name = "Linkedin"; url = "https://opportunity.linkedin.com/skills-for-in-demand-jobs/digital-marketer?trk=li-jobsindemand-digital-en"; }
                  { name = "CDkeys"; url = "https://www.cdkeys.com/"; }
                  { name = "g2a"; url = "https://g2a.com/"; }
                  { name = "Translate"; url = "https://translate.google.com/"; }
                  { name = "Sensitivity converter"; url = "https://gamingsmart.com/mouse-sensitivity-converter/"; }
                ];
              }
              {
                name = "Twitch";
                bookmarks = [
                  { name = "Twitch"; url = "https://www.twitch.tv/acethekell"; }
                  { name = "Stream Manager"; url = "https://dashboard.twitch.tv/u/acethekell/stream-manager"; }
                  { name = "Moobot"; url = "https://moo.bot/acethekell"; }
                  { name = "Streamlabs"; url = "https://streamlabs.com/dashboard"; }
                  { name = "StreamElements"; url = "https://streamelements.com/dashboard"; }
                  { name = "Linktree"; url = "https://linktr.ee/admin"; }
                ];
              }
              {
                name = "Save for later";
                bookmarks = [
                  { name = "DOOM Super Shotgun"; url = "https://www.thingiverse.com/thing:3981680"; }
                  { name = "RhymeZone"; url = "https://www.rhymezone.com/"; }
                  { name = "DOOM Story"; url = "https://steamcommunity.com/app/379720/discussions/0/3182216552779718496/"; }
                  { name = "BananaBread"; url = "https://kripken.github.io/misc-js-benchmarks/banana/game.html?low,low"; }
                  { name = "Wolfram|Alpha"; url = "https://www.wolframalpha.com/"; }
                  { name = "Shopify"; url = "https://cyberstep.myshopify.com/admin"; }
                  { name = "Thingiverse"; url = "https://www.thingiverse.com/"; }
                  { name = "Random Music Generators"; url = "https://random-music-generators.herokuapp.com/melody"; }
                  { name = "Iconic arms soundtrack"; url = "https://soundcloud.com/xahoy/sets/iconic-arms-season-2"; }
                  { name = "Neodymium Magnets"; url = "https://www.magnosphere.co.uk/strong-neodymium-magnets/disc-neodymium-magnets"; }
                  { name = "Silverback SRS Sniper"; url = "https://www.fire-support.co.uk/product/silverback-srs-a2m2-sport-16-black-stock-left-handed-sniper-rifle"; }
                  { name = "FMA Helmet Mandible"; url = "https://www.patrolbase.co.uk/fma-helmet-mandible-half-face-mask-for-fast-helmet?pv=14326"; }
                  { name = "MOTH3R Design"; url = "https://moth3r.com/"; }
                  { name = "Razer Kraken V3 X"; url = "https://www.ebuyer.com/1142403-razer-kraken-v3-x-wired-usb-gaming-headset-rz04-03750100-r3m1"; }
                  { name = "Hood pattern"; url = "https://sewguide.com/hood-pattern/"; }
                  { name = "EG Group"; url = "https://performancemanager.successfactors.eu/sf/liveprofile"; }
                  { name = "Calamity Mod Guide"; url = "https://calamitymod.wiki.gg/wiki/Guide:Class_setups"; }
                  { name = "CircuitMess"; url = "https://circuitmess.com/"; }
                  { name = "Homemade Smart Watch"; url = "https://www.instructables.com/Homemade-Smart-Watch/"; }
                ];
              }
              {
                name = "Destiny";
                bookmarks = [
                  { name = "Destinypedia"; url = "https://www.destinypedia.com/"; }
                  { name = "Destiny Reddit"; url = "https://www.reddit.com/r/DestinyTheGame/"; }
                  { name = "Destiny tracker"; url = "https://destinytracker.com/"; }
                  { name = "TodayInDestiny"; url = "https://www.todayindestiny.com/"; }
                  { name = "Xur"; url = "https://whereisxur.com/"; }
                  { name = "LFG"; url = "https://www.bungie.net/en/ClanV2/FireteamSearch?platform=4&activityType=0&lang=en&groupid=&"; }
                  { name = "Raid Report"; url = "https://raid.report/pc/4611686018486892910"; }
                  { name = "Checklist"; url = "https://destinyrecipes.com/checklist"; }
                  { name = "D2 Checklist"; url = "https://www.d2checklist.com/3/4611686018486892910/milestones"; }
                  { name = "vow"; url = "https://res.cloudinary.com/lmn/image/upload/e_sharpen:100/f_auto,fl_lossy,q_auto/v1/gameskinnyc/j/x/0/jx0ci81-6b8bd.jpeg"; }
                  { name = "Spreadsheet"; url = "https://docs.google.com/spreadsheets/d/10KwDBoZH8hV8NIvpjDRi9CfXIT4CGhdoIc-_KhtyIcI/edit?ouid=106511020629686694124&usp=sheets_home&ths=true"; }
                  { name = "D2Checkpoint"; url = "https://d2checkpoint.com/#"; }
                  { name = "Inventory"; url = "https://app.destinyitemmanager.com/4611686018486892910/d2/inventory"; }
                  { name = "light.gg"; url = "https://www.light.gg/"; }
                  { name = "FOUNDRY"; url = "https://d2foundry.gg/"; }
                ];
              }
              {
                name = "Projects";
                bookmarks = [
                  { name = "E-Paper HAT"; url = "https://www.waveshare.com/2.9inch-touch-e-paper-hat.htm"; }
                  { name = "explainshell"; url = "https://explainshell.com/"; }
                  { name = "Server"; url = "https://www.servercontrolpanel.de/SCP/Home?site_key=cgvUBiA3fMVkQi1URxGm9o98Q3sL5QCa"; }
                ];
              }
              {
                name = "Cars";
                bookmarks = [
                  { name = "KENGO NB ROADSTER"; url = "https://mazdafitment.com/2023/03/27/kengo-nb-roadster/"; }
                  { name = "SARD LSR WING"; url = "https://www.sard.co.jp/parts/products/wing/lsr_wing/"; }
                ];
              }
              {
                name = "Anime/manga";
                bookmarks = [
                  { name = "aniwatch.to"; url = "https://nepu.to/"; }
                  { name = "mangareader.to"; url = "https://mangareader.to/user/continue-reading"; }
                  { name = "NixOS pkgs"; url = "https://search.nixos.org/packages"; }
                ];
              }
              {
                name = "Nix";
                bookmarks = [
                  { name = "Noogle"; url = "https://noogle.dev/"; }
                  { name = "Nix Manual"; url = "https://nixos-and-flakes.thiscute.world/"; }
                ];
              }
              {
                name = "Spreadsheets";
                bookmarks = [
                  { name = "2022"; url = "https://docs.google.com/spreadsheets/d/1fCYCfTBEiBubLapnCfCvym0VoTCHwcO9/edit#gid=348003838"; }
                  { name = "2023"; url = "https://docs.google.com/spreadsheets/d/1Oat37avbEUajUm0A-oSp14KfulZJKY0qFFblAIWmjRg/edit#gid=0"; }
                ];
              }
              {
                name = "MMU";
                bookmarks = [
                  { name = "MyMMU"; url = "https://my.mmu.ac.uk/campusm/home#menu"; }
                  { name = "Security Certification Roadmap"; url = "https://pauljerimy.com/security-certification-roadmap/"; }
                ];
              }
              {
                name = "Archive";
                bookmarks = [
                  {
                    name = "D&D";
                    bookmarks = [
                      { name = "worldanvil"; url = "https://www.worldanvil.com/"; }
                      { name = "Dungeons & Destiny"; url = "https://velvetfanggames.com/dndestiny"; }
                      { name = "Smithing Stones"; url = "https://eldenring.wiki.fextralife.com/Smithing+Stones"; }
                      { name = "Necromancer 5e"; url = "https://www.dandwiki.com/wiki/Necromancer_(5e_Class)"; }
                    ];
                  }
                  {
                    name = "Airsoft";
                    bookmarks = [
                      { name = "Airsoft Spreadsheet"; url = "https://docs.google.com/spreadsheets/d/15DwMo3ED6Q9lURnUaDEAQXwuZoFuMXCca8rfDm3jcR4/edit#gid=2132113033"; }
                      {
                        name = "Titanfall build";
                        bookmarks = [
                          { name = "Jack cooper"; url = "https://i.pinimg.com/originals/19/9d/b0/199db024670346bbe5664774487f7fb3.jpg"; }
                          { name = "Camo idea"; url = "https://imgur.com/a/ea1Ov"; }
                          { name = "Coveralls"; url = "https://www.ebay.co.uk/itm/123045035863"; }
                          { name = "Hamster's guide"; url = "https://airsoft-forums.uk/topic/43707-hamster%E2%80%99s-guide-to-the-sort-of-science-of-pew-pewing/#comment-334396"; }
                        ];
                      }
                      {
                        name = "AAP-01";
                        bookmarks = [
                          { name = "Reciever"; url = "https://www.shootercbgear.com/new/index.php?route=product/product&product_id=12534"; }
                          { name = "Handguard"; url = "https://www.skirmshop.nl/en/aap-01-smg-handguard.html"; }
                          { name = "Trigger"; url = "https://www.skirmshop.nl/en/adjustable-trigger-for-aap-01-red.html"; }
                          { name = "Extended magazine"; url = "https://www.skirmshop.nl/en/extended-g-magazine-for-aap-01-and-g-series-50rds.html"; }
                          { name = "Steel Hammer set"; url = "https://www.skirmshop.nl/en/aap01-stainless-steel-hammer-set-cowcow.html"; }
                          { name = "Chronograph"; url = "https://www.acetk.com/products/ac5000"; }
                          { name = "Tracer"; url = "https://www.acetk.com/products/bifrost-m-tracer-unit-module"; }
                          { name = "Tracer BBs"; url = "https://www.acetk.com/products/acetech-tracer-bbs-greenred"; }
                          { name = "Mag grip"; url = "https://www.airsoftworld.net/action-army-aap-01-magazine-extended-grip.html"; }
                          { name = "Suppressor"; url = "https://www.airsoftworld.net/action-army-aap-01-ddw-suppressor-14mm-ccw-black.html"; }
                          { name = "Stock"; url = "https://www.airsoftworld.net/action-army-aap-01-folding-stock.html"; }
                          { name = "Lightweight bolt"; url = "https://www.airsoftworld.net/ctm-aap-01-7075-alu-superlight-bolt-black.html"; }
                          { name = "SGR-12 Shotgun"; url = "https://gunfire.com/en/products/sgr-12-electric-shotgun-replica-1152217005.html"; }
                          { name = "Rebel A180 Pistol"; url = "https://www.iwholesales.co.uk/airsoft-guns/110653-armorer-works-rebel-a180-pistol-gasblowback-pistol-black-silver"; }
                          { name = "Pirate Flintlock"; url = "https://www.iwholesales.co.uk/airsoft-guns/212777-hfc-pirate-flintlock-co2-18th-century-hg-502bn-silver"; }
                          { name = "BALYSTIK HPR800C"; url = "https://www.easy-airsoft.eu/shop/balystik-hpr800c-v3/"; }
                        ];
                      }
                    ];
                  }
                  {
                    name = "3D Prints";
                    bookmarks = [
                      { name = "Data knife"; url = "https://www.thingiverse.com/thing:2034348"; }
                      { name = "Battery housing"; url = "https://www.mouser.co.uk/ProductDetail/12BH510-GR?R=12BH510-GRvirtualkey56100000virtualkey12BH510-GR"; }
                      { name = "Power switch"; url = "http://www.mouser.com/Search/ProductDetail.aspx?R=SPPH410100virtualkey68800000virtualkey688-SPPH410100"; }
                      { name = "Buzzer"; url = "https://www.mouser.co.uk/ProductDetail/490-CPE-220?R=CPE-220virtualkey51780000virtualkey490-CPE-220"; }
                      { name = "Blue LEDs"; url = "https://www.mouser.co.uk/ProductDetail/941-C5SMFBJFCR0U0351"; }
                      { name = "7 segment display"; url = "https://www.sparkfun.com/products/11405"; }
                    ];
                  }
                ];
              }
              {
                name = "Blackwall";
                bookmarks = [
                  { name = "BRUTALIST HACKER NEWS"; url = "https://brutalisthackernews.com/top"; }
                  { name = "LandChad.net"; url = "https://landchad.net/"; }
                  { name = "100R"; url = "https://100r.co/site/home.html"; }
                  { name = "GrimGrains"; url = "https://grimgrains.com/site/home.html"; }
                  { name = "Merveilles"; url = "https://merveilles.town/about"; }
                  { name = "violet.fyi"; url = "https://violet.fyi/"; }
                  { name = "blackwall"; url = "https://10.0.0.10:8006/#v1:0:=node%2Fblackwall:4:=jsconsole:::::=consolejs:"; }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
