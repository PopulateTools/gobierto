![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto Budgets

## Budgets receipt format

Gobierto Budgets has a featured called Budgets receipt, that requires a configuration in JSON format. 

The JSON supports localized names and generic names:

- localized fields, such as `name_<locale>` will have preference
- otherwise the field `name` will be used

Here's an example of that JSON:

```json
{
  "budgets_simulation_sections": [{
      "name_es": "IBI",
      "name_ca": "IBI",
      "options": [{
          "name_es": "Vivienda 80m2 en el centro",
          "name_ca": "Habitatge 80m2 al centre",
          "value": 377.29
        },
        {
          "name": "Vivienda 130m2 en el centro",
          "value": 582.13
        },
        {
          "name": "Adosado en centro urbano",
          "value": 749.15
        },
        {
          "name": "Vivienda unifamiliar en urbanización",
          "value": 680.94
        }
      ]
    },
    {
      "name": "Vehículo",
      "options": [{
          "name": "Coche pequeño",
          "value": 59.81
        },
        {
          "name": "Coche mediano",
          "value": 128.92
        },
        {
          "name": "Coche grande",
          "value": 179.22
        }
      ]
    },
    {
      "name": "Vehículo adicional",
      "options": [{
          "name": "Coche pequeño",
          "value": 59.81
        },
        {
          "name": "Coche mediano",
          "value": 128.92
        },
        {
          "name": "Coche grande",
          "value": 179.22
        }
      ]
    },
    {
      "name": "Vado de vehículos",
      "options": [{
          "name": "Garaje comunitario",
          "value": 5
        },
        {
          "name": "Vivienda individual",
          "value": 40
        }
      ]
    }
  ]
}
```
