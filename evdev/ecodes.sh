#!/bin/bash

# Generate a Python extension module that exports macros from
# /usr/include/linux/input.h


header=${1:-/usr/include/linux/input.h}
[[ ! -e $header ]] && echo "no such file: $header" && exit 1


function codes () {
    cat ${header}  \
    | awk '/#define +(KEY|ABS|REL|SW|MSC|LED|BTN|REP|SND|ID|EV|BUS|SYN)_/ \
           {print "    PyModule_AddIntMacro(m, "$2");"}'
}

cat << EOF
#include <Python.h>
#include <linux/input.h>

/* Automatically generated by evdev/ecodes.sh */

#define MODULE_NAME "_ecodes"
#define MODULE_HELP "linux/input.h macros"

static PyMethodDef MethodTable[] = {
    { NULL, NULL, 0, NULL}
};

#if PY_MAJOR_VERSION >= 3
static struct PyModuleDef moduledef = {
    PyModuleDef_HEAD_INIT,
    MODULE_NAME,
    MODULE_HELP,
    -1,          /* m_size */
    MethodTable, /* m_methods */
    NULL,        /* m_reload */
    NULL,        /* m_traverse */
    NULL,        /* m_clear */
    NULL,        /* m_free */
};
#endif

static PyObject *
moduleinit(void)
{

#if PY_MAJOR_VERSION >= 3
    PyObject* m = PyModule_Create(&moduledef);
#else
    PyObject* m = Py_InitModule3(MODULE_NAME, MethodTable, MODULE_HELP);
#endif

    if (m == NULL) return NULL;

$(codes)

    return m;
}

#if PY_MAJOR_VERSION >= 3
PyMODINIT_FUNC
PyInit__ecodes(void)
{
    return moduleinit();
}
#else
PyMODINIT_FUNC
init_ecodes(void)
{
    moduleinit();
}
#endif
EOF
