module raytracer.camera;

class Camera {

    import raytracer.vector : Vector3;
    import raytracer.ray : Ray;

    private {
        const Vector3 _lowerLeft;
        const Vector3 _horizontal;
        const Vector3 _vertical;
        const Vector3 _origin;
    }

    /// Initialise camera with default parameters.
    this() {
        this._lowerLeft = Vector3(-2.0f, -1.0f, -1.0f);
        this._horizontal = Vector3(4.0f, 0.0f, 0.0f);
        this._vertical = Vector3(0.0f, 2.0f, 0.0f);
        this._origin = Vector3.zero();
    }

    Ray getRay(float u, float v) const {
        return Ray(_origin, _lowerLeft +  u*_horizontal + v*_vertical - _origin);
    }
}