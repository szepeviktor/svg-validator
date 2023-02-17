# Validate SVG files

This is an action for GitHub Actions. It runs `xmllint` on every matching SVG file.

```yaml
    - name: "Validate SVG files"
      uses: "szepeviktor/svg-validator@v0.1.0"
      with:
        svg_path: "public/**/*.svg"
```
