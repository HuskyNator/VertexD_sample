import std.stdio;
import vertexd;

import imageformats;

void main() {
	vdInit();
	Window window = new Window();
	// GltfReader lezer = new GltfReader("bestanden/NormalTangentTest/blender/normaltest..gltf");
	// GltfReader lezer = new GltfReader("bestanden/NormalTangentTest/glTF/NormalTangentTest.gltf");
	// GltfReader lezer = new GltfReader("bestanden/NormalTangentTest/blender/NormalTangentTest.gltf");
	GltfReader lezer = new GltfReader("bestanden/werelden/Sponza/NewSponza_Main_Blender_glTF.gltf");
	// GltfReader lezer = new GltfReader("bestanden/DamagedHelmet.gltf");
	// GltfReader lezer = new GltfReader("bestanden/schaaltje_steen.gltf");
	// GltfReader lezer = new GltfReader("bestanden/rekenmachine2.gltf");
	// GltfReader lezer = new GltfReader("bestanden/fox/Cameras.gltf");
	// GltfReader lezer = new GltfReader("bestanden/werelden/kleur.gltf");

	// Mesh m = lezer.meshes[0][0];
	// new File("blender", "wb").write(m.attributes[0].getContent);

	// GltfReader lezer2 = new GltfReader("bestanden/NormalTangentTest/gltf/NormalTangentTest.gltf");
	// Mesh m2 = lezer2.meshes[0][0];
	// new File("normal", "wb").write(m2.attributes[0].getContent);

	World world = lezer.main_world;
	window.world = world;
	Speler speler = new Speler("speler");
	world.addNode(speler);
	// window.world.addNode(speler);
	// Camera camera = new Camera(Camera.perspectiveProjection());
	// speler.addAttribute(new Light(Light.Type.FRAGMENT, Vec!3([1,1,1])));
	// world.currentCamera=camera;

	Camera camera = world.getCurrentCamera();
	// Node owner = camera.owner;
	// owner.removeAttribute(camera);
	// owner.addChild(speler);
	// speler.addAttribute(camera);

	window.setMouseType(MouseType.CAPTURED);
	window.keyCallbacks ~= &speler.toetsinvoer;
	// window.mousepositionCallbacks ~= &speler.muisinvoer;
	speler.location = Vec!3([0, 0, 2]);

	// Lines line = new Lines([[0, 0, 0], [1, 0, 0], [0, 0, 0], [0, 1, 0], [0, 0, 0], [0, 0, 1]], [
	// 		[1, 0, 0, 1], [1, 0, 0, 1], [0, 1, 0, 1], [0, 1, 0, 1], [0, 0, 1, 1], [0, 0, 1, 1]
	// 	]);
	// Lines line2 = new Lines([[0, 0, 0], [1, 1, 1]], [[1, 1, 0, 1]]);
	// world.roots[0].meshes ~= line;
	// world.roots[0].meshes ~= line2;

	vdLoop();
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
					Shader.gltfShader.setUniform("u_useNormalTexture", cast(uint) normalTexture);
					writeln("Normal Texture: " ~ (normalTexture ? "on" : "off"));
					break;
				case GLFW_KEY_3:
					if (input.event != GLFW_PRESS)
						break;
					colorTexture = !colorTexture;
					Shader.gltfShader.setUniform("u_useColorTexture", cast(uint) colorTexture);
					writeln("Color Texture: " ~ (colorTexture ? "on" : "off"));
					break;
				case GLFW_KEY_4:
					if (input.event != GLFW_PRESS)
						break;
					renderNormals = !renderNormals;
					Shader.gltfShader.setUniform("u_renderNormals", cast(uint) renderNormals);
					writeln("Render Normals: " ~ (renderNormals ? "on" : "off"));
					break;
				case GLFW_KEY_5:
					if (input.event != GLFW_PRESS)
						break;
					absNormals = !absNormals;
					Shader.gltfShader.setUniform("u_absNormals", cast(uint) absNormals);
					writeln("Render Absolute Normals: " ~ (absNormals ? "on" : "off"));
					break;
				case GLFW_KEY_6:
					if (input.event != GLFW_PRESS)
						break;
					renderTangents = !renderTangents;
					Shader.gltfShader.setUniform("u_renderTangents", cast(uint) renderTangents);
					writeln("Render Tangents: " ~ (renderTangents ? "on" : "off"));
					break;
				case GLFW_KEY_7:
					if (input.event != GLFW_PRESS)
						break;
					renderUV = !renderUV;
					Shader.gltfShader.setUniform("u_renderUV", cast(uint) renderUV);
					writeln("Render UV: " ~ (renderUV ? "on" : "off"));
					break;
				case GLFW_KEY_RIGHT:
					World world = worlds[0];
					if (cam < world.cameras.length - 1)
						cam += 1;
					world.currentCamera = world.cameras[cam];
					break;
				case GLFW_KEY_LEFT:
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
