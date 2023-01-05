import std.conv : to;
import std.datetime;
import std.datetime.stopwatch;
import std.stdio;
import vertexd;
import bindbc.opengl;

void main() {
	File log = File("log.txt", "a");
	debug log.write("(Debug) ");
	log.writeln("Run @: " ~ Clock.currTime.toSimpleString);

	vdInit();
	Window window = new Window();

	// StopWatch sw = StopWatch(AutoStart.yes);
	// GltfReader lezer = new GltfReader("bestanden/werelden/Sponza/NewSponza_Main_Blender_glTF.gltf");
	// sw.stop();
	// sw.peek.total!"msecs".writeln;
	// log.writeln("Gltf Setup: " ~ sw.peek.toString);

	GltfReader reader = new GltfReader("bestanden/DamagedHelmet.gltf");
	World world = reader.main_world;
	window.world = world;

	Speler speler = new Speler("speler");
	world.addNode(speler);

	Camera camera = new Camera(Camera.perspectiveProjection());
	speler.addAttribute(new Light(Light.Type.FRAGMENT, Vec!3([1, 1, 1])));
	speler.addAttribute(camera);
	world.currentCamera = camera;

	window.setMouseType(MouseType.CAPTURED);
	window.keyCallbacks ~= &speler.toetsinvoer;
	window.mousepositionCallbacks ~= &speler.muisinvoer;
	speler.location = Vec!3([0, 0, 2]);

	ShaderProgram.gltfShaderProgram.setUniform("u_useNormalTexture", cast(uint) true);
	ShaderProgram.gltfShaderProgram.setUniform("u_useColorTexture", cast(uint) true);

	vdStep();
	vdStep(); // Dont want to register initialization time
	// log.writeln("Average FPS (60 frames): " ~ vdDeltaTime().total!"msecs".to!string);
	vdDeltaTime().total!"usecs"
		.to!string
		.writeln;

	vdLoop();
	// vdDeInit();
}

class Speler : Node { // TODO: add switching camera
	private Quat xdraai;
	private Quat ydraai;

	private Vec!3 _verplaatsing;
	private Vec!2 _draai;
	private Vec!2 _draaiDelta;
	precision snelheid = 3;
	precision draaiSnelheid = 0.6;

	this(string name) {
		super();
		this.name = name;
	}

	bool culling = true;
	bool normalTexture = true;
	bool colorTexture = true;
	bool renderNormals = false;
	bool absNormals = false;
	bool renderTangents = false;
	bool renderUV = false;

	uint cam = 0;

	void toetsinvoer(KeyInput input) nothrow {
		try {
			import bindbc.glfw;
			import bindbc.opengl;

			if (input.event != GLFW_PRESS && input.event != GLFW_RELEASE)
				return;

			int delta = (input.event == GLFW_PRESS) ? 1 : -1;
			switch (input.key) {
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
				case GLFW_KEY_1:
					if (input.event != GLFW_PRESS)
						break;
					if (culling)
						glDisable(GL_CULL_FACE);
					else
						glEnable(GL_CULL_FACE);
					culling = !culling;
					writeln("Culling: " ~ (culling ? "on" : "off"));
					break;
				case GLFW_KEY_2:
					if (input.event != GLFW_PRESS)
						break;
					normalTexture = !normalTexture;
					ShaderProgram.gltfShaderProgram.setUniform("u_useNormalTexture", cast(uint) normalTexture);
					writeln("Normal Texture: " ~ (normalTexture ? "on" : "off"));
					break;
				case GLFW_KEY_3:
					if (input.event != GLFW_PRESS)
						break;
					colorTexture = !colorTexture;
					ShaderProgram.gltfShaderProgram.setUniform("u_useColorTexture", cast(uint) colorTexture);
					writeln("Color Texture: " ~ (colorTexture ? "on" : "off"));
					break;
				case GLFW_KEY_4:
					if (input.event != GLFW_PRESS)
						break;
					renderNormals = !renderNormals;
					ShaderProgram.gltfShaderProgram.setUniform("u_renderNormals", cast(uint) renderNormals);
					writeln("Render Normals: " ~ (renderNormals ? "on" : "off"));
					break;
				case GLFW_KEY_5:
					if (input.event != GLFW_PRESS)
						break;
					absNormals = !absNormals;
					ShaderProgram.gltfShaderProgram.setUniform("u_absNormals", cast(uint) absNormals);
					writeln("Render Absolute Normals: " ~ (absNormals ? "on" : "off"));
					break;
				case GLFW_KEY_6:
					if (input.event != GLFW_PRESS)
						break;
					renderTangents = !renderTangents;
					ShaderProgram.gltfShaderProgram.setUniform("u_renderTangents", cast(uint) renderTangents);
					writeln("Render Tangents: " ~ (renderTangents ? "on" : "off"));
					break;
				case GLFW_KEY_7:
					if (input.event != GLFW_PRESS)
						break;
					renderUV = !renderUV;
					ShaderProgram.gltfShaderProgram.setUniform("u_renderUV", cast(uint) renderUV);
					writeln("Render UV: " ~ (renderUV ? "on" : "off"));
					break;
				case GLFW_KEY_RIGHT:
					if (input.event != GLFW_RELEASE)
						break;
					World world = worlds[0];
					if (cam < world.cameras.length - 1)
						cam += 1;
					world.currentCamera = world.cameras[cam];
					break;
				case GLFW_KEY_LEFT:
					if (input.event != GLFW_RELEASE)
						break;
					World world = worlds[0];
					if (cam > 0)
						cam -= 1;
					world.currentCamera = world.cameras[cam];
					break;
				default:
			}
		} catch (Exception e) {
		}
	}

	void muisinvoer(MousepositionInput input) nothrow {
		static double oude_x = 0;
		static double oude_y = 0;
		_draaiDelta.y -= input.x - oude_x;
		_draaiDelta.x -= input.y - oude_y;
		oude_x = input.x;
		oude_y = input.y;
	}

	import std.datetime;

	override void logicStep(Duration deltaT) {
		import std.math;

		double deltaSec = deltaT.total!"hnsecs"() / 10_000_000.0;

		Vec!3 vooruit = ydraai * Vec!3([0, 0, -1]);
		Vec!3 rechts = ydraai * Vec!3([1, 0, 0]);

		Mat!3 verplaatsMat;
		verplaatsMat.setCol(0, rechts);
		verplaatsMat.setCol(1, Vec!3([0, 1, 0]));
		verplaatsMat.setCol(2, vooruit);

		this.location = this.location + cast(Vec!3)(verplaatsMat ^ (_verplaatsing * cast(prec)(snelheid * deltaSec)));

		_draaiDelta = _draaiDelta * cast(prec)(draaiSnelheid * deltaSec);
		_draai = _draai + _draaiDelta;
		if (abs(_draai.x) > PI_2)
			_draai.x = sgn(_draai.x) * PI_2;
		if (abs(_draai.y) > PI)
			_draai.y -= sgn(_draai.y) * 2 * PI;

		xdraai = Quat.rotation(Vec!3([1, 0, 0]), _draai.x);
		ydraai = Quat.rotation(Vec!3([0, 1, 0]), _draai.y);
		this.rotation = ydraai * xdraai;

		_draaiDelta = Vec!2(0);

		super.logicStep(deltaT);
	}
}
