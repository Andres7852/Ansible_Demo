# 🚀 Demostración Práctica de Ansible: Gestión de la Configuración

Este repositorio contiene un ejemplo real, limpio y directo para demostrar los conceptos fundamentales de **Gestión de la Configuración** e **Infraestructura como Código (IaC)** con **Ansible**.

---

## 🎯 Objetivo de la Demostración

Aprovisionar y configurar de forma automatizada un servidor web **Nginx** en un entorno Linux (WSL Ubuntu), desplegando una página web corporativa dinámica mediante plantillas **Jinja2** y comprobando en vivo la **idempotencia** del sistema.

### Conceptos Clave que Demuestra:

1. **Arquitectura Agentless:** No requiere agentes propietarios; gestiona nodos mediante conexiones nativas (Local / SSH).
2. **Definición Declarativa:** Describimos el estado deseado en YAML (`playbook.yml`), no scripts imperativos con pasos manuales.
3. **Idempotencia:** Si el servidor ya cumple con el estado deseado, Ansible no realiza modificaciones innecesarias (`changed=0`).
4. **Configuration as Code (CaC):** El inventario, las variables y las plantillas están versionados en código.

---

## 📁 Estructura del Proyecto

```text
Ansible_Demo/
├── inventory/
│   └── hosts.ini          # Inventario de nodos a administrar
├── templates/
│   └── index.html.j2      # Plantilla Jinja2 dinámica con Ansible Facts
├── ansible.cfg            # Configuración general de Ansible
├── playbook.yml           # Playbook principal con tareas declarativas
├── run_demo.sh            # Script automatizado para Linux / WSL
├── run_demo.ps1           # Script lanzador desde PowerShell (Windows)
└── README.md              # Documentación y guía del expositor
```

---

## ⚙️ Requisitos Previos

1. **Windows 10/11 con WSL (Ubuntu):**
   - Ya configurado en el sistema.
2. **Ansible instalado en WSL:**
   - Ya se encuentra instalado (`ansible [core 2.20.1]`).
   - Si se requiere instalar en otro equipo:
     ```bash
     sudo apt-get update
     sudo apt-get install -y ansible-core
     ```

---

## 🎬 Paso a Paso para la ejecución

Abre tu terminal en WSL Ubuntu:

```bash
cd "/mnt/c/Visual PJ/Ansible_Demo"
```

#### Paso 1: Prueba de Conectividad (Ad-hoc Ping)

Verifica que Ansible puede comunicarse con el inventario:

```bash
ansible webservers -i inventory/hosts.ini -m ping
```

- "Ansible utiliza el módulo `ping` para validar que el nodo responde y tiene el intérprete de Python listo, sin haber ejecutado aún ninguna modificación."

#### Paso 2: Simulación de Cambios (Dry-Run / Check Mode)

Evalúa qué acciones se ejecutarían sin aplicar ningún cambio real:

```bash
ansible-playbook -i inventory/hosts.ini playbook.yml --check
```

- "El modo `--check` permite auditar y predecir el impacto de nuestro código antes de tocar producción. Esto evita sorpresas y errores humanos."

#### Paso 3: Ejecución Real del Playbook

Aplica el estado deseado en el servidor:

```bash
ansible-playbook -i inventory/hosts.ini playbook.yml
```

- "Ansible lee de arriba hacia abajo:
  1. Instala el paquete `nginx` con el módulo `apt`.
  2. Genera `/var/www/html/index.html` inyectando variables del sistema (hostname, fecha, distribución OS) gracias a la plantilla Jinja2.
  3. Asegura que el servicio `nginx` esté iniciado y habilitado en el arranque.
  4. Si hubo cambios en la plantilla, dispara el `handler` para recargar el servicio."

#### Paso 4: Verificación en el Navegador

Abre en tu navegador favorito:
👉 **[http://localhost](http://localhost)**

Verás la página web moderna con el estado del servidor, los facts obtenidos en tiempo real por Ansible y la confirmación de despliegue.

---

### ⭐ El potencial de Ansible

### 1. Idempotencia

Vuelve a ejecutar inmediatamente el mismo comando:

```bash
ansible-playbook -i inventory/hosts.ini playbook.yml
```

- **Qué observar en el resumen final (`PLAY RECAP`):**
  ```text
  localhost : ok=4  changed=0  unreachable=0  failed=0
  ```
- "Como pueden observar en la terminal, todas las tareas reportaron `ok` y el contador `changed` es 0. Esta es la **Idempotencia**: podemos ejecutar el Playbook 1 o 100 veces, y Ansible solo modificará aquello que realmente difiera del estado deseado."

---

### 2. Autocuración (Self-Healing) y Configuration Drift

"¿Qué pasa si alguien altera o rompe el servidor manualmente?" :

1. **Simula un fallo humano apagando el servidor web:**

   ```bash
   sudo service nginx stop
   ```

   _(Opcional: puedes borrar también el archivo web: `sudo rm /var/www/html/index.html`)_

2. **Muestra el navegador y recarga la página [http://localhost](http://localhost):**  
   Verán que la página está caída (_"No se puede acceder a este sitio"_).

3. **Ejecuta nuevamente Ansible para restaurar el estado deseado:**

   ```bash
   ansible-playbook -i inventory/hosts.ini playbook.yml
   ```

4. **Qué observar en la terminal:**  
   Ansible detecta de inmediato la desviación (_Drift_) y corrige la falla:

   ```text
   TASK [3. Asegurar que el servicio Nginx este activo y habilitado] **************
   changed: [localhost]

   PLAY RECAP *********************************************************************
   localhost                  : ok=4    changed=1    unreachable=0    failed=0
   ```

5. **Recarga [http://localhost](http://localhost):**  
   ¡El sitio web vuelve a estar activo inmediatamente sin intervención manual!

- "Esto demuestra la **Autocuración (Self-Healing)** y la solución al **Configuration Drift** (Diapositiva 2): sin importar qué errores manuales ocurran en el servidor, Ansible garantiza que la infraestructura regrese exactamente al estado deseado definido en el código."\*

---

### 3. Actualización Controlada (Configuration as Code)

Si quieres mostrar cómo aplicar un cambio de software o versión de manera formal:

1. En `playbook.yml`, cambia la versión a `"2.0.0"`:
   ```yaml
   vars:
     app_version: "2.0.0"
   ```
2. Ejecuta `ansible-playbook -i inventory/hosts.ini playbook.yml`.
3. Verás que solo se actualiza la plantilla HTML (`changed: 2`) y se reinicia el servicio Nginx.
4. Al recargar [http://localhost](http://localhost), verás en pantalla **`v2.0.0 (IaC Gestionado)`**.

---

## 🔍 Explicación del Código

### 1. `inventory/hosts.ini`

Define a qué máquinas aplicaremos la configuración:

```ini
[webservers]
localhost ansible_connection=local
```

- `ansible_connection=local`: Ejecuta directamente en el entorno local sin requerir llaves SSH para la demo. En producción, aquí se colocan las IPs de servidores remotos (`server1 ansible_host=192.168.1.50 ansible_user=ubuntu`).

### 2. `playbook.yml`

```yaml
---
- name: Despliegue y Configuracion de Servidor Web Nginx
  hosts: webservers
  become: true # Ejecutar con permisos de superusuario (sudo)
  vars:
    app_title: "Ansible Demo - Gestion de la Configuracion"
    app_version: "1.0.0"

  tasks:
    - name: 1. Instalar servidor web Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: 2. Desplegar sitio web personalizado desde plantilla Jinja2
      template:
        src: templates/index.html.j2
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: "0644"
      notify: Reiniciar Nginx

    - name: 3. Asegurar que el servicio Nginx este activo y habilitado
      service:
        name: nginx
        state: started
        enabled: yes

  handlers:
    - name: Reiniciar Nginx
      service:
        name: nginx
        state: restarted
```
