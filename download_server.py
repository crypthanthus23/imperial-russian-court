from flask import Flask, render_template, send_file
import os
import zipfile
from io import BytesIO

app = Flask(__name__)

@app.route('/')
def index():
    # Get all LSL files
    lsl_files = [f for f in os.listdir('.') if f.endswith('.lsl')]
    lsl_files.sort()  # Sort alphabetically
    
    # Organize by module
    modules = {}
    for file in lsl_files:
        # Extract the module name from the file name
        parts = file.split('_')
        if len(parts) > 1:
            module = parts[1]
            if module not in modules:
                modules[module] = []
            modules[module].append(file)
    
    return render_template('index.html', lsl_files=lsl_files, modules=modules)

@app.route('/download/<filename>')
def download_file(filename):
    return send_file(filename, as_attachment=True)

@app.route('/download_all')
def download_all():
    # Get all LSL files
    lsl_files = [f for f in os.listdir('.') if f.endswith('.lsl')]
    
    # Create a BytesIO object to store the zip file
    memory_file = BytesIO()
    
    # Create the zip file
    with zipfile.ZipFile(memory_file, 'w') as zf:
        for file in lsl_files:
            zf.write(file)
    
    # Seek to the beginning of the BytesIO object
    memory_file.seek(0)
    
    return send_file(
        memory_file,
        mimetype='application/zip',
        as_attachment=True,
        download_name='Imperial_Court_Scripts.zip'
    )

@app.route('/download_module/<module>')
def download_module(module):
    # Get all LSL files for this module
    lsl_files = [f for f in os.listdir('.') if f.endswith('.lsl') and f.startswith(f'Imperial_{module}')]
    
    # Create a BytesIO object to store the zip file
    memory_file = BytesIO()
    
    # Create the zip file
    with zipfile.ZipFile(memory_file, 'w') as zf:
        for file in lsl_files:
            zf.write(file)
    
    # Seek to the beginning of the BytesIO object
    memory_file.seek(0)
    
    return send_file(
        memory_file,
        mimetype='application/zip',
        as_attachment=True,
        download_name=f'Imperial_{module}_Module.zip'
    )

if __name__ == '__main__':
    # Create templates directory if it doesn't exist
    if not os.path.exists('templates'):
        os.makedirs('templates')
    
    # Create index.html template
    with open('templates/index.html', 'w') as f:
        f.write('''
<!DOCTYPE html>
<html>
<head>
    <title>Imperial Russian Court Roleplay System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #8B0000;
            text-align: center;
        }
        h2 {
            color: #8B0000;
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
        }
        .download-all {
            display: block;
            width: 200px;
            margin: 20px auto;
            padding: 10px;
            background-color: #8B0000;
            color: white;
            text-align: center;
            text-decoration: none;
            border-radius: 5px;
        }
        .module {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 5px;
        }
        .file-link {
            display: block;
            padding: 5px;
            color: #333;
            text-decoration: none;
        }
        .file-link:hover {
            background-color: #eee;
        }
        .module-download {
            display: block;
            width: 150px;
            margin-top: 10px;
            padding: 5px;
            background-color: #8B0000;
            color: white;
            text-align: center;
            text-decoration: none;
            border-radius: 5px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Imperial Russian Court Roleplay System</h1>
        <p>Sistema avanzado de scripts LSL para roleplay de la Corte Imperial Rusa en Second Life</p>
        
        <a href="/download_all" class="download-all">Descargar Todo</a>
        
        <h2>Archivos por Módulo</h2>
        {% for module, files in modules.items() %}
        <div class="module">
            <h3>Módulo: {{ module }}</h3>
            {% for file in files %}
            <a href="/download/{{ file }}" class="file-link">{{ file }}</a>
            {% endfor %}
            <a href="/download_module/{{ module }}" class="module-download">Descargar Módulo</a>
        </div>
        {% endfor %}
        
        <h2>Todos los Archivos</h2>
        {% for file in lsl_files %}
        <a href="/download/{{ file }}" class="file-link">{{ file }}</a>
        {% endfor %}
    </div>
</body>
</html>
        ''')
    
    # Run the server
    app.run(host='0.0.0.0', port=5000)