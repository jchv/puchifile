{
	description = "A mobile file manager.";

	inputs = {
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, flake-utils }:
		flake-utils.lib.eachDefaultSystem (system:
			let
				name = "puchifile";
				src = ./.;
				pkgs = nixpkgs.legacyPackages.${system};
			in
			{
				packages.default = pkgs.stdenv.mkDerivation {
					inherit name src;
					nativeBuildInputs = with pkgs; [
						vala
						meson
						ninja
						pkg-config
						wrapGAppsHook4
						gobject-introspection
					];
					buildInputs = with pkgs; [
						gtk4
						glib
						gsettings-desktop-schemas
						gdk-pixbuf
						gnome-desktop
						libadwaita
					];
					meta = with nixpkgs.lib; {
						homepage = "TODO";
						description = "A mobile file manager.";
						platforms = platforms.linux;
					};
				};
			}
		);
}
