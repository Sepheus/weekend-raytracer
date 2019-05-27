import std.stdio;
import raytracer.raytracer;

/// Stores image width, height, depth and raw pixels.
struct Image {
    /// Image width in pixels.
    int width;
    /// Image height in pixels.
    int height;
    /// Image depth in bytes per pixel.
    int depth = 3;
    /// Raw pixel data in floats.
    float[][] pixels;
    /// Initialise image with weight and height.
    this(int width, int height) {
        this.width = width;
        this.height = height;
        this.pixels = new float[][](this.width * this.height, this.depth);
    }
}

// If piping from console, make sure console is UTF-8.
void main() {
    render()
        .ppm();
}

/// Simulate matte material difraction.
Vector3 diffuse() {
    import std.random : uniform01;
    import std.typecons : scoped;
    Vector3 p;
    do {
        p = 2.0f * scoped!Vector3(uniform01(), uniform01(), uniform01()) - Vector3.one();
    } while(p.sqrMagnitude >= 1.0f);
    return p;
}

/// Linear blend to arrive at the correct colour for the position along the ray.
Vector3 colour() (in auto ref Ray r, in HitableList world) {
    immutable rec = world.hit(r, 0.001, float.max);
    static const c = new Vector3(0.5f, 0.7f, 1.0f);
    if(rec.hit) {
        const target = rec.point + rec.normal + diffuse();
        return 0.5f * Ray(rec.point, target-rec.point).colour(world);
    }
    immutable unit_direction = Vector3.normalized(r.direction());
    immutable t = (unit_direction.y + 1.0f)*0.5f;
    return Vector3.lerp(Vector3.one(), c, t);
}

/// Render the scene.
Image render() {
    import std.parallelism : parallel;
    import std.random : uniform01;
    import std.math : sqrt;
    Image output = Image(400, 200);
    immutable samples = 100.0f;
    HitableList world = new HitableList();
    const camera = new Camera();
    world.add(new Sphere(new Vector3(0.0f, 0.0f, -1.0f), 0.5f));
    world.add(new Sphere(new Vector3(0.0f, -100.5f, -1.0f), 100.0f));
    foreach(i, ref pixel; output.pixels.parallel) {
        auto col = new Vector3(0.0f, 0.0f, 0.0f);
        immutable x = (i % output.width);
        immutable y = ((output.height - 1.0f) - (i / output.width));
        foreach(_; 0 .. samples) {
            immutable u = (x + uniform01()) / output.width;
            immutable v = (y + uniform01()) / output.height;
            col += camera
                        .getRay(u, v)
                        .colour(world);
        }
        col /= samples;
        pixel = [col.x.sqrt, col.y.sqrt, col.z.sqrt];
    }
    return output;
}

/// Output image data in ppm format.
void ppm() (in auto ref Image image) {
    import std.format : format;
    import std.algorithm : map;
    immutable header = "%s\n%s %s\n255";
    immutable pix = "%(%0.f %)";
    header
        .format("P3",image.width, image.height)
        .writeln;
    foreach(i, ref pixel; image.pixels) {
        pix
            .format(pixel.map!(n => n * 255))
            .writeln;
    }
}