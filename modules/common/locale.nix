# Locale and timezone settings
{ config, lib, ... }:

{
  time.timeZone = "Europe/Jersey";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
}
