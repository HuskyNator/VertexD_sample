import std.stdio;
import hoekjed;
import bindbc.opengl;
import bindbc.glfw;

const char* vertexShaderString =
	`#version 450 core
    layout (location = 0) in vec3 pos;
    void main(){
       gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);
    }`;

const char* fragmentShaderString =
	`#version 450 core
	out vec4 color;
	void main(){
		color = vec4(0, 1, 0, 1.0f);
	}`;

void main() {
	glfwInit();
	GLFWwindow* window = glfwCreateWindow(1920 / 2, 1080 / 2, "A", null, null);
	glfwMakeContextCurrent(window);

	loadOpenGL();
	glEnable(GL_DEPTH_TEST);

	float[9] driehoek = [
		-0.5f, -0.5f, 0.0f,
		0.5f, -0.5f, 0.0f,
		0.0f, 0.5f, 0.0f
	];
	// uint[3] index = [0, 1, 2];

	uint vao;
	glCreateVertexArrays(1, &vao);

	uint buffer;
	glCreateBuffers(1, &buffer);
	glNamedBufferStorage(buffer, driehoek.sizeof, &driehoek, 0);
	glEnableVertexArrayAttrib(vao, 0);
	glVertexArrayAttribFormat(vao, 0, 3, GL_FLOAT, false, 0);
	glVertexArrayAttribBinding(vao, 0, 0);
	glVertexArrayVertexBuffer(vao, 0, buffer, 0, 3*float.sizeof);

	// uint indexbuffer;
	// glCreateBuffers(1, &indexbuffer);
	// glNamedBufferStorage(indexbuffer, index.sizeof, &index, 0);
	// glVertexArrayElementBuffer(vao, indexbuffer);

	uint vertexShader = glCreateShader(GL_VERTEX_SHADER);
	uint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(vertexShader, 1, &vertexShaderString, null);
	glShaderSource(fragmentShader, 1, &fragmentShaderString, null);
	glCompileShader(vertexShader);
	glCompileShader(fragmentShader);

	uint shader = glCreateProgram();
	glAttachShader(shader, vertexShader);
	glAttachShader(shader, fragmentShader);
	glLinkProgram(shader);
	glUseProgram(shader);

	while (!glfwWindowShouldClose(window)) {
		glViewport(0, 0, 1920 / 2, 1080 / 2);

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); // Verschoont het scherm.

		glBindVertexArray(vao);
		glDrawArrays(GL_TRIANGLES, 0, 3);
		// glDrawElements(GL_TRIANGLES, 3, GL_UNSIGNED_INT, cast(void*) 0);

		glfwSwapBuffers(window);
		glfwPollEvents();
	}
}
