import std.stdio;
import hoekjed;

void main() {
	hdZetOp();
	Venster venster = new Venster();
	GltfLezer lezer = new GltfLezer("blok.gltf");
	venster.wereld = lezer.hoofd_wereld;
	Voorwerp speler = new Voorwerp("speler");
	venster.wereld.kinderen ~= speler;
	Zicht zicht = new Zicht("zicht", Zicht.perspectiefProjectie(), speler);
	venster.wereld.zicht = zicht;
	lezer.voorwerpen[0].plek = Vec!3([0,0,-5]);

	hdLus();
}
