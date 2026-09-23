{ inputs, primaryUser, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    extraSpecialArgs = { inherit inputs primaryUser; };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${primaryUser} = import ../home/hardik;
  };
}
