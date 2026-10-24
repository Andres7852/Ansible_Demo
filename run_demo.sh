#!/usr/bin/env bash
# Script para correr la demostración de Ansible
set -e

# Asegurar que estamos en el directorio del script
cd "$(dirname "$0")"
export ANSIBLE_CONFIG="$(pwd)/ansible.cfg"

echo "=========================================================="
echo "    ANSIBLE DEMO: GESTION DE CONFIGURACION EN ACCION      "
echo "=========================================================="
echo ""

echo "[PASO 1/3] Verificando conectividad con el inventario (ansible ping)..."
ansible webservers -i inventory/hosts.ini -m ping
echo ""

echo "[PASO 2/3] Modo Simulacion (Dry-Run / Check Mode)..."
echo "Evaluando que cambios se ejecutarian sin alterar el sistema..."
ansible-playbook -i inventory/hosts.ini playbook.yml --check
echo ""

echo "[PASO 3/3] Ejecucion Real del Playbook (Aplicando Estado Deseado)..."
ansible-playbook -i inventory/hosts.ini playbook.yml
echo ""

echo "=========================================================="
echo " [OK] Despliegue completado con exito!"
echo " Abre tu navegador en: http://localhost"
echo "=========================================================="
echo ""
echo "CONSEJO PARA LA EXPOSICION (IDEMPOTENCIA):"
echo "Ejecuta de nuevo este comando:"
echo "  ansible-playbook -i inventory/hosts.ini playbook.yml"
echo "Veras que todas las tareas reportan 'ok' y 'changed=0'."
echo "=========================================================="
