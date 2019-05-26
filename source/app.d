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

/// Linear blend to arrive at the correct colour for the position along the ray.
Vector3 colour() (in auto ref Ray r, in HitableList world) {
    HitRecord rec;
    if(world.hit(r, 0.0f, float.max, rec)) { 
        return 0.5f * new Vector3(rec.normal.x + 1.0f, rec.normal.y + 1.0f, rec.normal.z + 1.0f);
    }
    auto unit_direction = Vector3.normalized(r.direction());
    float t = (unit_direction.y + 1.0f)*0.5f;
    return Vector3.lerp(Vector3.one(), new Vector3(0.5f, 0.7f, 1.0f), t);
}

/// Render the scene.
Image render() {
    import std.parallelism : parallel;
    Image output = Image(200, 100);
    const lowerLeft = new Vector3(-2.0f, -1.0f, -1.0f);
    const horizontal = new Vector3(4.0f, 0.0f, 0.0f);
    const vertical = new Vector3(0.0f, 2.0f, 0.0f);
    const origin = Vector3.zero();
    HitableList world = new HitableList();
    world.add(new Sphere(new Vector3(0.0f, 0.0f, -1.0f), 0.5f));
    world.add(new Sphere(new Vector3(0.0f, -100.5f, -1.0f), 100.0f));
    foreach(i, ref pixel; output.pixels.parallel) {
        immutable u = (i % output.width) / cast(float) output.width;
        immutable v = ((output.height - 1.0f) - (i / output.width)) / output.height;
        immutable calc = lowerLeft + u*horizontal + v*vertical;
        const col = Ray(origin, calc).colour(world);
        pixel = [col.get_x, col.get_y, col.get_z];
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