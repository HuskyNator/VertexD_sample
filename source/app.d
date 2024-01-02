import std.conv : to;
import std.datetime;
import std.datetime.stopwatch;
import std.stdio;
import vertexd;
import bindbc.opengl;

void main() {
	vdInit();
	Window window = new Window();

	GltfReader reader = new GltfReader("resources/DamagedHelmet/DamagedHelmet.gltf");
	World world = reader.main_world;
	window.world = world;

	Speler speler = new Speler("speler");
	world.addNode(speler);

	Camera camera = new Camera(Camera.perspectiveProjection());
	speler.addAttribute(new Light(Light.Type.POINT, Vec!3(1, 1, 1)));
	speler.addAttribute(camera);
	world.currentCamera = camera;

	window.setMouseType(MouseType.CAPTURED);
	window.keyCallbacks ~= &speler.toetsinvoer;
	window.mousepositionCallbacks ~= &speler.mouseInput;
	speler.location = Vec!3(0, 0, 2);

	ShaderProgram.gltfShaderProgram.setUniform("u_useNormalTexture", cast(uint) true);
	ShaderProgram.gltfShaderProgram.setUniform("u_useColorTexture", cast(uint) true);

	vdLoop();
}

class Speler : Node {
	private Quat xRot;
	private Quat yRot;

	private Vec!3 _displacement;
	private Vec!2 _rotation;
	private Vec!2 _rotationDelta;
	precision speed = 3;
	precision rotationSpeed = 0.6;

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
				_displacement.x -= delta;
				break;
			case GLFW_KEY_D:
				_displacement.x += delta;
				break;
			case GLFW_KEY_SPACE:
				_displacement.y += delta;
				break;
			case GLFW_KEY_LEFT_CONTROL:
				_displacement.y -= delta;
				break;
			case GLFW_KEY_S:
				_displacement.z -= delta;
				break;
			case GLFW_KEY_W:
				_displacement.z += delta;
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
			default:
			}
		} catch (Exception e) {
		}
	}

	void mouseInput(MousepositionInput input) nothrow {
		static double old_x = 0;
		static double old_y = 0;
		_rotationDelta.y -= input.x - old_x;
		_rotationDelta.x -= input.y - old_y;
		old_x = input.x;
		old_y = input.y;
	}

	import std.datetime;

	override void logicStep(Duration deltaT) {
		import std.math;

		double deltaSec = deltaT.total!"hnsecs"() / 10_000_000.0;

		Vec!3 forward = yRot * Vec!3([0, 0, -1]);
		Vec!3 right = yRot * Vec!3([1, 0, 0]);

		Mat!3 displaceMat;
		displaceMat.setCol(0, right);
		displaceMat.setCol(1, Vec!3([0, 1, 0]));
		displaceMat.setCol(2, forward);

		this.location = this.location + cast(Vec!3)(
			displaceMat ^ (_displacement * cast(prec)(speed * deltaSec)));

		_rotationDelta = _rotationDelta * cast(prec)(rotationSpeed * deltaSec);
		_rotation = _rotation + _rotationDelta;
		if (abs(_rotation.x) > PI_2)
			_rotation.x = sgn(_rotation.x) * PI_2;
		if (abs(_rotation.y) > PI)
			_rotation.y -= sgn(_rotation.y) * 2 * PI;

		xRot = Quat.rotation(Vec!3([1, 0, 0]), _rotation.x);
		yRot = Quat.rotation(Vec!3([0, 1, 0]), _rotation.y);
		this.rotation = yRot * xRot;

		_rotationDelta = Vec!2(0);

		super.logicStep(deltaT);
	}
}
