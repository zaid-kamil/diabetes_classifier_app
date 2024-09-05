import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../ml_utils/classifier.dart';

class PredictionWeb extends StatefulWidget {
  const PredictionWeb({super.key});

  @override
  State<PredictionWeb> createState() => _PredictionWebState();
}

class _PredictionWebState extends State<PredictionWeb> {
  // variables for training the model
  Map<String, double> trainResult = {};

  // variables for making predictions
  String? prediction;
  final _formKey = GlobalKey<FormBuilderState>();

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      print('Form is valid');
      print(_formKey.currentState?.value);
      var formData = _formKey.currentState?.value;

      makePrediction(formData!).then((value) {
        setState(() {
          if (value == '1') {
            prediction = 'Diabetes detected';
          } else {
            prediction = 'No diabetes detected';
          }
        });
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      prediction = null;
    });
  }

  Future<void> _trainDiabetesModel() async {
    Map<String, double> result = await trainModel();
    setState(() {
      trainResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diabetes Prediction Web App',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple,
                Colors.deepPurpleAccent,
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            "images/bg.png",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            colorBlendMode: BlendMode.modulate,
            color: Colors.purple.withOpacity(0.1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DiabetesPredictionForm(
                  formKey: _formKey,
                  submitForm: _submitForm,
                  resetForm: _resetForm,
                ),
              ),
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: .75,
                  widthFactor: .90,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          color: Colors.white.withAlpha(250),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.refresh_rounded),
                              onPressed: _trainDiabetesModel,
                              label: const Text('Train Model'),
                            ),
                            const Text("Train the model to make predictions",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w100,
                                )),
                            const SizedBox(height: 20),
                            trainResult.isEmpty
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Train the model to get metrics'),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Accuracy: ${trainResult['accuracy']?.toStringAsFixed(2)}",
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Recall: ${trainResult['recall']?.toStringAsFixed(2)}",
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Precision: ${trainResult['precision']?.toStringAsFixed(2)}",
                                      ),
                                    ],
                                  )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: AnimatedContainer(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: switchColor(prediction),
                          ),
                          duration: const Duration(seconds: 1),
                          child: Center(
                            child: Text(
                              prediction != null
                                  ? prediction!
                                  : 'Prediction will appear here',
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  switchColor(String? prediction) {
    if (prediction == 'Diabetes detected') {
      return Colors.red.withAlpha(200);
    } else if (prediction == 'No diabetes detected') {
      return Colors.green.withAlpha(200);
    } else {
      return Colors.grey.withAlpha(200);
    }
  }
}

class DiabetesPredictionForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final VoidCallback submitForm;
  final VoidCallback resetForm;

  const DiabetesPredictionForm({
    super.key,
    required this.formKey,
    required this.submitForm,
    required this.resetForm,
  });

  @override
  Widget build(BuildContext context) {
    var gapBwInput = 20.0;
    return FractionallySizedBox(
      heightFactor: .75,
      widthFactor: .90,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          color: Colors.white.withAlpha(250),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: this.formKey,
              child: Column(
                children: [
                  Text(
                    'Enter details of the patient',
                    style: TextStyle(
                      fontSize: gapBwInput,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: gapBwInput),
                  FormBuilderTextField(
                    name: 'Pregnancies',
                    decoration: const InputDecoration(
                      labelText: 'Number of Pregnancies',
                      icon: Icon(Icons.numbers_outlined),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                    ]),
                  ),
                  SizedBox(height: gapBwInput),
                  FormBuilderTextField(
                    name: 'Glucose',
                    decoration: const InputDecoration(
                      labelText: 'Oral Glucose Level (mg/dL)',
                      icon: Icon(Icons.local_hospital_outlined),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                    ]),
                  ),
                  SizedBox(height: gapBwInput),
                  FormBuilderTextField(
                    name: 'BloodPressure',
                    decoration: const InputDecoration(
                      labelText: 'Blood Pressure (mm Hg)',
                      icon: Icon(Icons.medical_services_outlined),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                    ]),
                  ),
                  SizedBox(height: gapBwInput),
                  FormBuilderTextField(
                    name: 'SkinThickness',
                    decoration: const InputDecoration(
                      labelText: 'Triceps Skin Thickness (mm)',
                      icon: Icon(Icons.person_outline),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                    ]),
                  ),
                  SizedBox(height: gapBwInput),
                  FormBuilderTextField(
                    name: 'Insulin',
                    decoration: const InputDecoration(
                      labelText: 'Insulin Level (mu U/ml)',
                      icon: Icon(Icons.medical_services_outlined),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                    ]),
                  ),
                  SizedBox(height: gapBwInput),
                  FormBuilderTextField(
                    name: 'BMI',
                    decoration: const InputDecoration(
                      labelText: 'Body Mass Index (BMI)',
                      icon: Icon(Icons.monitor_weight_outlined),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                    ]),
                  ),
                  SizedBox(height: gapBwInput),
                  FormBuilderTextField(
                    name: 'DiabetesPedigreeFunction',
                    decoration: const InputDecoration(
                      labelText:
                          'Diabetes Pedigree (History of Diabetes in Family)',
                      hintText: "Enter 0 or 1 only",
                      icon: Icon(Icons.monitor_weight_outlined),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.max(3),
                      FormBuilderValidators.min(0),
                    ]),
                  ),
                  SizedBox(height: gapBwInput),
                  FormBuilderTextField(
                    name: 'Age',
                    decoration: const InputDecoration(
                      labelText: 'Age of the patient',
                      icon: Icon(Icons.person_outline),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.numeric(),
                    ]),
                  ),
                  SizedBox(height: gapBwInput),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.clear),
                        onPressed: resetForm,
                        label: const Text(
                          'Reset',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        icon: const Icon(Icons.check),
                        onPressed: submitForm,
                        label: const Text(
                          'Predict',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gapBwInput),
                ],
                // ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
