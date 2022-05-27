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
	private Quat xdraai;
	private Quat ydraai;

	private Vec!3 _verplaatsing;
	private Vec!2 _draai;
	private Vec!2 _draaiDelta;
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
			_verplaatsing.x -= delta;
			break;
		case GLFW_KEY_D:
			_verplaatsing.x += delta;
			break;
		case GLFW_KEY_SPACE:
			_verplaatsing.y += delta;
			break;
		case GLFW_KEY_LEFT_CONTROL:
			_verplaatsing.y -= delta;
			break;
		case GLFW_KEY_S:
			_verplaatsing.z -= delta;
			break;
		case GLFW_KEY_W:
			_verplaatsing.z += delta;
			break;
		default:
		}
	}

	void muisinvoer(MuisplekInvoer invoer) nothrow {
		static double oude_x = 0;
		static double oude_y = 0;
		_draaiDelta.y -= invoer.x - oude_x;
		_draaiDelta.x -= invoer.y - oude_y;
		oude_x = invoer.x;
		oude_y = invoer.y;
	}

	import std.datetime;

	override void denkStap(Duration deltaT) {
		import std.math;

		double deltaSec = deltaT.total!"hnsecs"() / 10_000_000.0;

		Vec!3 vooruit = ydraai * Vec!3([0, 0, -1]);
		Vec!3 rechts = ydraai * Vec!3([1, 0, 0]);

		Mat!3 verplaatsMat;
		verplaatsMat.zetKol(0, rechts);
		verplaatsMat.zetKol(1, Vec!3([0, 1, 0]));
		verplaatsMat.zetKol(2, vooruit);

		this.plek = this.plek + cast(Vec!3)(
			verplaatsMat ^ (_verplaatsing * cast(nauw)(snelheid * deltaSec)));

		_draaiDelta = _draaiDelta * cast(nauw)(draaiSnelheid * deltaSec);
		_draai = _draai + _draaiDelta;
		if (abs(_draai.x) > PI_2)
			_draai.x = sgn(_draai.x) * PI_2;
		if (abs(_draai.y) > PI)
			_draai.y -= sgn(_draai.y) * 2 * PI;

		xdraai = Quat.draai(Vec!3([1, 0, 0]), _draai.x);
		ydraai = Quat.draai(Vec!3([0, 1, 0]), _draai.y);
		this.draai = ydraai * xdraai;

		_draaiDelta = Vec!2(0);

		super.denkStap(deltaT);
	}
}
