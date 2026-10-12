.PHONY: build run play clean sprites install-godot check-godot

build: check-godot
	mkdir -p build/web
	touch build/.gitignore
	.bin/godot --headless --export-release "Web"

run: build
	@echo "Open http://localhost:8000 in your browser (Ctrl+C to stop)"
	python3 -m http.server 8000 --bind 127.0.0.1 -d build/web

play:
	godot-4 --path .

clean:
	rm -rf build

# Rewrites the item PNGs from the pixel grids in tools/make_sprites.gd.
sprites: check-godot
	.bin/godot --headless --path . --script res://tools/make_sprites.gd
	.bin/godot --headless --import

# ._sc_ puts Godot in self-contained mode, so its settings and export templates stay in .bin/.
install-godot:
	mkdir -p .bin
	touch .bin/._sc_
	mkdir -p .bin/editor_data/export_templates/4.7.2.stable
	# download
	curl -fL -o .bin/godot.zip https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
	curl -fL -o .bin/templates.tpz https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz
	# unzip
	unzip -p .bin/godot.zip > .bin/godot
	unzip -j -o .bin/templates.tpz templates/version.txt 'templates/web_nothreads_*' -d .bin/editor_data/export_templates/4.7.2.stable
	# clean up
	rm .bin/godot.zip
	rm .bin/templates.tpz
	# make executable
	chmod +x .bin/godot

check-godot:
	@test -x .bin/godot || { \
		echo "Godot not found at .bin/godot. Run 'make install-godot' first."; \
		exit 1; \
	}
