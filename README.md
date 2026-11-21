# Gestor de Tareas y Proyectos (Propuesta 2) - GESTOR PRO

**Asignatura:** Ingeniería de Software II - Parcial de Patrones de Diseño  
**Lenguaje:** Java
**Integrantes:**  
- David Andres Fajardo Briceño
- Charlotte Samantha García Galindo 

---

## 1. Definición Inicial del Proyecto

### 1.1 Alcance del sistema
Para este proyecto vamos a construir una aplicación de escritorio en Java enfocada en organizar tareas personales o de un equipo pequeño, permitiendo usar tanto una interfaz por consola como una ventana gráfica sencilla sobre la misma lógica de negocio.

#### **Funcionalidades que se van a implementar:**
- **Tareas simples y tareas compuestas:** Posibilidad de crear tareas individuales o tareas padre (proyectos/módulos) que agrupen varias subtareas.
- **Control de estados y transiciones:** Manejo de los estados *Pendiente*, *En curso*, *En revisión* y *Terminada*, validando qué cambios de estado son válidos y cuáles no.
- **Deshacer y rehacer acciones (Undo / Redo):** Historial en memoria para revertir o volver a aplicar acciones recientes como crear una tarea, editarla, cambiarle el estado o eliminarla.
- **Ordenamiento y filtrado dinámico:** Opciones para listar tareas ordenadas o filtradas por prioridad, fecha límite o persona responsable.
- **Alertas de vencimiento:** Avisos en pantalla cuando existen tareas próximas a vencer o que ya pasaron su fecha límite.

#### **Funcionalidades que quedan por fuera (y por qué):**
- **Plantillas para proyectos recurrentes:** Se dejan por fuera para mantener el alcance realista frente al tiempo de entrega y concentrarnos en que los patrones principales queden bien implementados y con buenas pruebas unitarias.
- **Envío de notificaciones externas (correo o SMS):** No se incluyen porque el sistema funciona de manera local en Java estándar y agregar servidores de correo complicaría la ejecución sin aportar a los patrones centrales del parcial.
- 

---

### 1.2. Requisitos del Sistema

#### Requisitos Funcionales (RF)
- **RF01 - [Tareas]:** El sistema debe permitir crear tareas simples y tareas compuestas (que contienen otras tareas). 
- **RF02 - [Atributos]:** El sistema debe permitir asignar a cada tarea atributos básicos: título, descripción, responsable, fecha límite y nivel de prioridad.  
- **RF03 - [Estados]:** El sistema debe permitir cambiar el estado de una tarea (Pendiente, En curso, En revisión, Terminada) respetando reglas lógicas (ej. no se puede pasar a "Terminada" si está "Pendiente" sin pasar por "En curso"). 
- **RF04 - [Actualización del Estado]:** El sistema debe actualizar automáticamente el estado de una tarea compuesta si todas sus subtareas son marcadas como "Terminadas". 
- **RF05 - [Filtrado y Visualización]:** El sistema debe permitir visualizar la lista de tareas ordenadas y filtradas según el criterio que elija el usuario (por prioridad, por fecha límite o por responsable).

#### Requisitos No Funcionales (RNF)
- **RNF01 - [Lenguaje]:** El sistema debe estar desarrollado en Java. 
- **RNF02 - [Arquitectura dual]:** La lógica de negocio debe estar totalmente separada de las vistas. El sistema debe poder ejecutarse tanto por consola como mediante una interfaz gráfica sencilla usando exactamente el mismo núcleo (core). 
- **RNF03 - [Extensibilidad]:** El código debe aplicar principios SOLID y patrones de diseño (creacionales, estructurales y/o de comportamiento) para resolver problemas de flexibilidad. 
- **RNF04 - [Trabajo colaborativo]:** El proyecto se gestionará en un repositorio Git, donde debe quedar el historial de commits reflejando el trabajo equitativo de los dos integrantes. 
- **RNF05 - [Calidad]:** Las clases críticas donde se apliquen los patrones de diseño deben contar con pruebas unitarias que garanticen su correcto funcionamiento.

---
### 1.3 Problemas de diseño identificados
Si programáramos este gestor de forma directa y sin aplicar patrones, nos encontraríamos con varios problemas a medida que crece el código:

1. **Manejo desigual entre tareas individuales y tareas con subtareas:**  
   Si creamos una clase `Tarea` y otra clase aparte llamada `Proyecto` que guarda una lista de tareas, cada vez que queramos mostrar el listado, calcular el progreso o contar cuántas tareas faltan, tocaría llenar el código de `if (objeto instanceof Proyecto)` y casteos. Además, si luego queremos meter una subtarea dentro de otra subtarea, esa estructura rígida no lo permitiría fácilmente.

2. **Lógica de estados llena de condicionales (`if/else`):**  
   Cada estado de una tarea tiene reglas distintas: una tarea *Pendiente* se puede editar y pasar a *En curso*, pero no se puede dar por *Terminada* de una vez; una tarea *Terminada* ya no debería dejarse modificar ni devolver a *Pendiente*. Si metemos todas esas validaciones dentro de un `switch` gigante en la clase `Tarea`, cualquier cambio o estado nuevo (como *Bloqueada*) obligaría a tocar toda la clase y aumentaría el riesgo de dañar lo que ya funciona.

3. **Dificultad para implementar Deshacer y Rehacer:**  
   El usuario necesita revertir cambios en las tareas. Si intentamos guardar una copia completa de toda la lista de tareas cada vez que alguien edita un título o cambia un estado, gastaríamos memoria innecesaria y además mezclaríamos la lógica de los botones/menús con el historial de cambios.

4. **Ordenamiento y filtrado rígido:**  
   Al principio solo ordenamos por prioridad o fecha, pero en cualquier momento puede surgir la necesidad de ordenar por responsable o filtrar por estado. Si ponemos métodos separados como `ordenarPorFecha()` y `ordenarPorPrioridad()` llenos de condicionales dentro de la clase gestora, cada criterio nuevo obligaría a modificar el núcleo del sistema.
   
---

## 4. Arquitectura General

### Separación de capas
- **Lógica de negocio (`modelo` / `patrones`):** [Explicar qué contiene y cómo se mantiene independiente]
- **Capa de servicio (`servicio`):** [Explicar cómo coordina la lógica]
- **Interfaz de consola (`vista.consola`):** [Explicar cómo se conecta al núcleo]
- **Interfaz gráfica (`vista.gui`):** [Explicar cómo se conecta al mismo núcleo]

### Estructura de paquetes del repositorio
```text
src/
├── main/
│   └── java/
│       └── com/gestor/
│           ├── modelo/
│           ├── patrones/
│           ├── servicio/
│           └── vista/
│               ├── consola/
│               └── gui/
└── test/
    └── java/
        └── com/gestor/
```

---

## 3. Patrones de Diseño Aplicados

### 3.1 Patrón Composite (Estructural)

- **Problema concreto:** El sistema debe soportar tanto tareas individuales como tareas compuestas por múltiples subtareas, permitiendo consultar su estado, prioridad o porcentaje de avance sin importar si se trata de una tarea suelta o de un grupo completo.
- **Descripción con palabras propias:** El patrón Composite sirve para armar estructuras en forma de árbol donde las piezas individuales y los grupos de piezas se manejan exactamente igual desde afuera. Así, el resto del programa no tiene que estar preguntando si algo es una tarea sola o una carpeta llena de subtareas; simplemente llama al mismo método y cada objeto responde según lo que es.
- **Correspondencia de roles y clases:**

| Rol del Patrón | Clase / Interfaz en el Proyecto | Responsabilidad |
| :--- | :--- | :--- |
| **Component** | `ComponenteTarea` | Define las operaciones comunes (`getTitulo()`, `obtenerProgreso()`, `mostrarDetalle()`, `cambiarEstado()`). |
| **Leaf (Hoja)** | `TareaSimple` | Representa una tarea individual que no tiene hijos. Su progreso es 100% si está terminada o 0% si no. |
| **Composite** | `TareaCompuesta` | Contiene una lista de `ComponenteTarea` (subtareas) y calcula su progreso promediando el de sus hijos. |

- **Alternativa considerada y por qué se descartó:** Se pensó en crear una clase `Proyecto` totalmente separada de `Tarea` con una lista interna de tareas. Se descartó porque impediría anidar subtareas dentro de otras subtareas y obligaría a duplicar métodos en el servicio para listar y calcular avances por separado.
- **Ventajas, desventajas y relación con SOLID:**
  - *Ventajas:* Simplifica el código cliente (consola y Swing), facilita agregar niveles de subtareas sin cambios estructurales y evita el uso de `instanceof`.
  - *Desventajas:* Puede hacer que la interfaz común tenga métodos (como `agregarSubtarea()`) que no tienen sentido en una `TareaSimple`, obligando a lanzar una excepción controlada si se intentan llamar ahí.
  - *Relación con SOLID:* Cumple con **Abierto/Cerrado (OCP)** porque permite introducir nuevos tipos de componentes sin alterar el código que los recorre, y con **Sustitución de Liskov (LSP)** al permitir que una `TareaCompuesta` se use en cualquier lugar donde se espere un `ComponenteTarea`.

---

### 3.2 Patrón State (Comportamiento)

- **Problema concreto:** Las tareas pasan por cuatro estados (*Pendiente*, *En curso*, *En revisión*, *Terminada*) y existen reglas estrictas sobre qué transiciones son válidas y qué acciones se pueden hacer en cada momento.
- **Descripción con palabras propias:** State consiste en sacar el comportamiento de cada estado fuera de la clase principal y meterlo en clases pequeñas e independientes. En lugar de que la tarea tenga un montón de condicionales revisando en qué estado está parada, la tarea guarda una referencia a un objeto "estado actual" y le delega la decisión de si puede avanzar, retroceder o editarse.
- **Correspondencia de roles y clases:**

| Rol del Patrón | Clase / Interfaz en el Proyecto | Responsabilidad |
| :--- | :--- | :--- |
| **Context** | `ComponenteTarea` | Mantiene la referencia al `EstadoTarea` actual y expone métodos como `iniciar()`, `enviarARevision()` y `finalizar()`. |
| **State** | `EstadoTarea` | Interfaz que declara las transiciones posibles y validaciones según el estado. |
| **ConcreteState** | `EstadoPendiente`, `EstadoEnCurso`, `EstadoEnRevision`, `EstadoTerminada` | Implementan las reglas exactas de cada fase (por ejemplo, `EstadoPendiente` solo permite pasar a `EstadoEnCurso`). |

- **Alternativa considerada y por qué se descartó:** Usar un `enum Estado` junto con bloques `switch` dentro de `Tarea`. Se descartó porque a medida que se agregan reglas (como bloquear la edición cuando ya está *Terminada*), la clase `Tarea` se vuelve muy larga y difícil de leer.
- **Ventajas, desventajas y relación con SOLID:**
  - *Ventajas:* Elimina condicionales repetitivos, hace muy explícitas las transiciones válidas y facilita agregar un estado nuevo en el futuro (por ejemplo, *Cancelada*) creando una sola clase.
  - *Desventajas:* Aumenta la cantidad de clases pequeñas en el paquete de estados, lo cual puede verse algo verboso si las reglas fueran muy simples.
  - *Relación con SOLID:* Aplica **Responsabilidad Única (SRP)** al aislar la lógica de cada estado en su propia clase, y **Abierto/Cerrado (OCP)** al permitir añadir nuevos estados sin modificar la clase `Tarea`.

---

### 3.3 Patrón Command (Comportamiento)

- **Problema concreto:** El usuario necesita poder deshacer y rehacer acciones realizadas sobre las tareas (como crear, eliminar o cambiar de estado) desde ambas interfaces.
- **Descripción con palabras propias:** Command convierte cada acción que pide el usuario en un objeto independiente que sabe cómo ejecutarse y cómo revertirse. De esta forma, podemos guardar esos objetos en dos pilas (una para deshacer y otra para rehacer) sin que la interfaz gráfica ni la consola tengan que saber cómo se revierte internamente cada operación.
- **Correspondencia de roles y clases:**

| Rol del Patrón | Clase / Interfaz en el Proyecto | Responsabilidad |
| :--- | :--- | :--- |
| **Command** | `Comando` | Interfaz con los métodos `ejecutar()` y `deshacer()`. |
| **ConcreteCommand** | `ComandoCrearTarea`, `ComandoEliminarTarea`, `ComandoCambiarEstado`, `ComandoEditarTarea` | Guardan los datos necesarios antes del cambio (como el estado anterior) para poder revertirlo después. |
| **Invoker** | `HistorialComandos` | Administra las pilas `pilaUndo` y `pilaRedo` y ejecuta los comandos solicitados. |
| **Receiver** | `GestorTareasService` / `ComponenteTarea` | Objetos reales sobre los cuales se aplican o revierten las modificaciones. |

- **Alternativa considerada y por qué se descartó:** Se evaluó el patrón *Memento*, guardando una copia completa de toda la lista de tareas antes de cada operación. Se descartó porque clonar árboles completos de tareas compuestas cada vez que se edita un campo consume más memoria y es más propenso a errores de referencia que guardar solo el delta de la acción puntual.
- **Ventajas, desventajas y relación con SOLID:**
  - *Ventajas:* Permite implementar Undo/Redo de manera limpia y reutilizable tanto en consola como en Swing, y desacopla los botones de la lógica que ejecuta la acción.
  - *Desventajas:* Requiere crear una clase nueva por cada operación que queramos que sea reversible.
  - *Relación con SOLID:* Cumple con **Responsabilidad Única (SRP)** al separar la invocación de la ejecución, y con **Abierto/Cerrado (OCP)** porque agregar una nueva acción reversible no requiere tocar el `HistorialComandos`.

---

### 3.4 Patrón Strategy (Comportamiento)

- **Problema concreto:** El sistema debe permitir ordenar y filtrar las tareas por distintos criterios (prioridad, fecha límite o responsable) y estar preparado para añadir criterios nuevos fácilmente.
- **Descripción con palabras propias:** Strategy consiste en encapsular diferentes formas de hacer una misma tarea (en nuestro caso, ordenar o filtrar una lista) dentro de clases intercambiables. Así el gestor principal no tiene quemada una única forma de ordenar, sino que recibe la estrategia que el usuario escoja en ese momento y la aplica sobre las tareas.
- **Correspondencia de roles y clases:**

| Rol del Patrón | Clase / Interfaz en el Proyecto | Responsabilidad |
| :--- | :--- | :--- |
| **Context** | `GestorTareasService` | Recibe una estrategia activa y la utiliza cuando se solicita el listado de tareas. |
| **Strategy** | `EstrategiaOrden` / `EstrategiaFiltro` | Interfaces que definen el contrato `ordenar(List<ComponenteTarea>)` y `filtrar(List<ComponenteTarea>)`. |
| **ConcreteStrategy** | `OrdenPorPrioridad`, `OrdenPorFecha`, `OrdenPorResponsable`, `FiltroPorResponsable`, `FiltroPorPrioridad` | Implementan cada criterio específico de comparación o filtrado. |

- **Alternativa considerada y por qué se descartó:** Implementar `Comparable` directamente en `ComponenteTarea` o poner varios `if` en el servicio según un parámetro de texto. Se descartó porque `Comparable` solo permite un orden natural fijo y los `if` obligarían a modificar el servicio cada vez que se pida un ordenamiento nuevo.
- **Ventajas, desventajas y relación con SOLID:**
  - *Ventajas:* Permite cambiar el criterio de ordenamiento o filtrado en tiempo de ejecución desde un combo box en Swing o una opción en consola, y facilita agregar criterios nuevos en segundos.
  - *Desventajas:* El cliente o controlador debe conocer qué estrategias existen para instanciar la correcta según la selección del usuario.
  - *Relación con SOLID:* Cumple con **Abierto/Cerrado (OCP)** al permitir añadir nuevas estrategias sin tocar el gestor, y con **Inversión de Dependencias (DIP)** porque `GestorTareasService` depende de la abstracción `EstrategiaOrden` y no de implementaciones concretas.
---

### 5.2 Patrón 2: [Nombre del Patrón] ([Categoría])
- **Problema concreto:** [Qué problema del proyecto motivó su uso]
- **Descripción con palabras propias:** [Explicación sencilla de cómo funciona el patrón]
- **Correspondencia de roles y clases:**

| Rol del Patrón | Clase / Interfaz en el Proyecto | Responsabilidad |
| :--- | :--- | :--- |
| [Rol 1] | `[NombreClase]` | [Qué hace] |
| [Rol 2] | `[NombreClase]` | [Qué hace] |
| [Rol 3] | `[NombreClase]` | [Qué hace] |

- **Alternativa considerada y por qué se descartó:** [Qué otra opción se pensó y por qué no convenía]
- **Ventajas, desventajas y relación con SOLID:**
  - *Ventajas:* [Escribir aquí]
  - *Desventajas:* [Escribir aquí]
  - *Principios SOLID:* [Qué principios cumple y por qué]

---


---

## 6. Diagramas UML

### 6.1 Diagrama de Casos de Uso


### 6.2 Diagrama de Clases General

### 6.3 Diagramas de Clases por Patrón
#### Patrón 1 - [Nombre]


#### Patrón 2 - [Nombre]


#### Patrón 3 - [Nombre]


### 6.4 Diagrama de Secuencia


---

## 7. Instrucciones de Compilación y Ejecución

### Requisitos previos
- Java JDK [17 / 21] instalado.
- [Maven / Gradle / Compilación manual con `javac`].

### Ejecutar versión por Consola
```bash
# Pegar aquí el comando para compilar y correr la consola
```

### Ejecutar versión con Interfaz Gráfica (GUI)
```bash
# Pegar aquí el comando para compilar y correr la ventana gráfica
```

### Ejecutar Pruebas Unitarias
```bash
# Pegar aquí el comando para correr las pruebas con JUnit
```

---

## 8. Conclusiones

- **¿Qué se aprendió?**  
  [Escribir aprendizajes del equipo sobre el diseño y los patrones]

- **¿Qué se cambiaría del diseño?**  
  [Escribir mejoras que harían en una futura versión]

---

## 9. Integridad Académica y Declaración de Herramientas

- [Declarar aquí si se usaron herramientas de IA o fuentes externas, para qué se utilizaron y confirmar que todos los integrantes comprenden y pueden sustentar el proyecto]
- 

