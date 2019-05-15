import std.stdio;

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
    this(int width, int height) {
        this.width = width;
        this.height = height;
        this.pixels = new float[][](this.width * this.height, this.depth);
    }
}

void main() {
    generate()
        .ppm();
}

/// Generate the 200x100 test gradient.
Image generate() {
    Image output = Image(200, 100);
    int p = 0;
    foreach_reverse(j; 0.0f .. output.height) {
        foreach(i; 0.0f .. output.width) {
            output.pixels[p++] = [i / output.width, j / output.height, 0.2];
        }
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
            .format(pixel.map!(n => n * 256))
            .writeln;
    }
}