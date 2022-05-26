import std.stdio;
import hoekjed;

void main() {
	hdZetOp();
	Venster venster = new Venster();
	GltfLezer lezer = new GltfLezer("bestanden/werelden/Sponza/NewSponza_Main_Blender_glTF.gltf");
	Wereld wereld = lezer.hoofd_wereld;
	venster.wereld = wereld;
	Speler speler = new Speler("speler");
	venster.wereld.kinderen ~= speler;
	Zicht zicht = new Zicht(Zicht.perspectiefProjectie());
	speler.eigenschappen ~= zicht;
	venster.wereld.zicht = zicht;
	lezer.voorwerpen[0].plek = Vec!3([0, 0, -5]);

	venster.zetMuissoort(Muissoort.GEVANGEN);
	venster.toetsTerugroepers ~= &speler.toetsinvoer;
	venster.muisplekTerugroepers ~= &speler.muisinvoer;
	speler.plek = Vec!3([1, 1, 0]);
	hdLus();
}

class Speler : Voorwerp {

	private Vec!3 verplaatsing;
	private Vec!3 draaiing;
	nauwkeurigheid snelheid = 3;
	nauwkeurigheid draaiSnelheid = 0.6;

	this(string naam) {
		super(naam);
	}

	void toetsinvoer(ToetsInvoer invoer) nothrow {
		import bindbc.glfw;

		if (invoer.gebeurtenis != GLFW_PRESS && invoer.gebeurtenis != GLFW_RELEASE)
			return;

		int delta = (invoer.gebeurtenis == GLFW_PRESS) ? 1 : -1;
		switch (invoer.toets) {
		case GLFW_KEY_A:
			verplaatsing.x -= delta;
			break;
		case GLFW_KEY_D:
			verplaatsing.x += delta;
			break;
		case GLFW_KEY_SPACE:
			verplaatsing.y += delta;
			break;
		case GLFW_KEY_LEFT_CONTROL:
			verplaatsing.y -= delta;
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

	void muisinvoer(MuisplekInvoer invoer) nothrow {
		static double oude_x = 0;
		static double oude_y = 0;
		double delta_x = invoer.x - oude_x;
		double delta_y = invoer.y - oude_y;
		draaiing.y -= delta_x;
		draaiing.x -= delta_y;
		oude_x = invoer.x;
		oude_y = invoer.y;
	}

	import std.datetime;

	override void denkStap(Duration deltaT) {
		import std.math : abs;

		double deltaSec = deltaT.total!"hnsecs"() / 10_000_000.0;
		this.plek = plek + Mat!(3).draaiMy(draai.y).maal(verplaatsing * cast(nauwkeurigheid)(snelheid * deltaSec));

		Vec!3 draaiDelta = draaiing * cast(nauwkeurigheid)(draaiSnelheid * deltaSec);
		if (abs(draai.x + draaiDelta.x) > 3.14)
			draaiDelta.x = 0;
		this.draai = draai + draaiDelta;
		draaiing = Vec!3(0);

		super.denkStap(deltaT);
	}
}
