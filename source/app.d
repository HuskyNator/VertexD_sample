import std.stdio;
import hoekjed;

void main() {
	hdZetOp();
	Venster venster = new Venster();
	GltfLezer lezer = new GltfLezer("blok.gltf");
	venster.wereld = lezer.hoofd_wereld;
	Speler speler = new Speler("speler");
	venster.wereld.kinderen ~= speler;
	Zicht zicht = new Zicht("zicht", Zicht.perspectiefProjectie(), speler);
	venster.wereld.zicht = zicht;
	lezer.voorwerpen[0].plek = Vec!3([0, 0, -5]);

	venster.toetsTerugroepers ~= &speler.toetsinvoer;

	hdLus();
}

class Speler : Voorwerp {

	private Vec!3 verplaatsing;
	nauwkeurigheid snelheid = 0.25;

	this(string naam) {
		super(naam);
	}

	void toetsinvoer(ToetsInvoer invoer) nothrow {
		import bindbc.glfw;

		if (invoer.gebeurtenis != GLFW_PRESS && invoer.gebeurtenis != GLFW_RELEASE)
			return;

		int delta = (invoer.gebeurtenis == GLFW_PRESS)?1:-1;
		switch (invoer.toets) {
		case GLFW_KEY_A:
			verplaatsing.x -= delta;
			break;
		case GLFW_KEY_D:
			verplaatsing.x += delta;
			break;
		case GLFW_KEY_S:
			verplaatsing.z += delta;
			break;
		case GLFW_KEY_W:
			verplaatsing.z -= delta;
			break;
		default:
		}
	}

	import std.datetime;

	override void denkStap(Duration deltaT) {
		verplaatsing.writeln();
		this.plek = this.plek + verplaatsing * snelheid * deltaT.total!"seconds"();
		super.denkStap(deltaT);
	}
}
