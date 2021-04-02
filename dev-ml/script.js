// DEVELOPMENT PLANS FOR APRIL 1
// TODO: Complete Prediction Input
// TODO: Multiple Inputs
/*
  Multiple inputs would undoubtedly have to account for the following:
  - Difference in data selection and extraction
  - Difference in model specification
  - Difference in tensor conversion
  - Difference in testing and data prediction UI.
 */
// TODO: Layers Specifier (Make something that appears to work...)


console.log("Hello SOCR!")

// File upload button
let inputField = document.getElementById('fileInput')
// Preview of file attributes
let infoField = document.getElementById('fileInfoContainer')
// Submit file and load data
let viewButton = document.getElementById('viewFile')

// Set of fields for selecting and loading feature and label data
// TODO: Set up multiple feature input
let featureField = document.getElementById('featureSelection')
let labelField = document.getElementById('labelSelection')
let confirmButton = document.getElementById('confirmSelection')
let dataLoaded = document.getElementById('loadComplete')

// let testMultiple = document.getElementById('multidimensionalTest')

let trainingStarter = document.getElementById('trainingStarter')
let testingStarter = document.getElementById('testingStarter')
let modelPredictionContainer = document.getElementById('modelPredictionContainer')
let predictionButton = document.getElementById('confirmPredictionInput')
let predictionOutput = document.getElementById('predictedValueContainer')

let optimizerSelector = document.getElementById('optimizerSelector')
let lossSelector = document.getElementById('lossSelector')
let metricSelector = document.getElementById('metricSelector')
let batchSizeSelector = document.getElementById('batchSize')
let epochSelector = document.getElementById('epochNumber')

let csvObject;
let file, model, data = [], tensorData;

let featureName, labelName;
let predictionInputTrackers = [];
let predictionInputData = [];

/** Operation to be completed when the user selects a file upload */
function uploadOperation() {
	file = this.files[0];
	const timeModified = new Date(file.lastModified).toLocaleString('en-US');

	infoField.innerText = ""; // Clear div container
	infoField.innerText += ("name : " + file.name + "\n");
	infoField.innerText += ("size : " + file.size + "\n");
	infoField.innerText += ("type : " + file.type + "\n");
	infoField.innerText += ("date : " + timeModified + "\n");
	console.log("Document uploaded!");

	// TODO: Implement all these parameters as customizable UI Interfaces!
	Papa.parse(file, {
		// TODO: Batch processing for ridiculously large csv files?
		// TODO: Implement customizable dynamic typing in the near future
		dynamicTyping : true,
		complete: function(results) {
			console.log(results);
			csvObject = results;
		}
	});
}


/**
 * Loads attributes of the dataset into the selection fields for features and
 * labels
 */
function loadAttributes() {
	// Extract first row from the csv
	// I know that not all data are like this!
	let attributes = csvObject['data'][0]
	if (featureField)
	featureField.innerHTML = "";
	labelField.innerHTML = "";

	// TODO: Group data by types, for example, doubles vs. strings vs. other
  //  pieces of shit.
	for (let i = 0; i < attributes.length; i++) {
		featureField.innerHTML += "<option value = \"" + attributes[i] +
			"\">" + attributes[i] + "</option>";
		labelField.innerHTML += "<option value = \"" + attributes[i] +
			"\">" + attributes[i] + "</option>";
	}

}

/**
 * Return an array of the selected values select is an HTML select element
 * @param A variable pointing to an HTML <select> tag
 */
function getSelectValues(select) {
  let result = [];
  const options = select && select.options;
  let opt;

  for (let i=0, iLen=options.length; i<iLen; i++) {
    opt = options[i];

    if (opt.selected) {
      result.push(opt.value || opt.text);
    }
  }
  return result;
}


/**
 * Load data into the feature and label fields according to the attributes
 * selected by the user
 */
function loadData() {
  data = [];
	dataLoaded.innerText = '';

	// String names of the features and labels
	const featureList = getSelectValues(featureField);
	const labelList = getSelectValues(labelField);
	// Indices of the features and labels in the first row of the dataset
  const featureIndices = featureList.map(x => csvObject['data'][0].indexOf(x))
  const labelIndices = labelList.map(x => csvObject['data'][0].indexOf(x))

	console.log("featureList: ", featureList)
  console.log("labelList: ", labelList)
  console.log("featureIndices: ", featureIndices)
  console.log("labelIndices: ", labelIndices)

	// Load prediction parameters
  modelPredictionContainer.innerHTML = "";
  predictionInputTrackers = [];
  for (let i=0; i < featureList.length; i++) {
    modelPredictionContainer.innerHTML += "<div>"+ featureList[i] + "</div>" +
      "<input type=\"text\" id=\"" + featureList[i] +
      "\" name=\"" + featureList[i] + "\"/> ";
    predictionInputTrackers.push(document.getElementById(featureList[i]))
  }

  /*
   * A sample dataItem in the data array is in the following form...
   * dataItem = {
   *   "features": [featureOne, featureTwo, etc.];
   *   "labels": [labelOne, labelTwo, etc.];
   * }
   *
   * In 1D, this would equate to...
   * dataItem = {
   *   "features": [feature]
   *   "labels": [label]
   * }
   */
  // Extract data from the csv object by column
  // Skip first row with the string attributes
  for (let i = 1; i < csvObject['data'].length; i++) {
    let dataItem = {}
    dataItem['features'] = featureIndices.map(x => csvObject['data'][i][x])
    dataItem['labels'] = labelIndices.map(x => csvObject['data'][i][x])
    if (i == 1) console.log(dataItem) // for debugging
    data.push(dataItem)
  }

  // Ad-hoc solution for single input and output
	// featureName = featureList[0]
	// labelName = labelList[0]
  // const featureIndex = csvObject['data'][0].indexOf(featureName);
  // const labelIndex = csvObject['data'][0].indexOf(labelName);
	// convertArrayToTensor(data, featureList, labelList)

	// const datasetSize = data.length;
	dataLoaded.innerText += 'Features and Labels loaded and converted to' +
		' tensors. \n';
	dataLoaded.innerText += 'Total number of feature-label pairs: ' +
		data.length + '\n';
}

// TODO: This may not be the most efficient way to loop through a f**kton of
//  data
function convertArrayToTensor(data, featureList, labelList) {
  // Step 0. Clean data
  for (let inputItem = 0; inputItem < featureList.length; inputItem++) {
    data = data.filter(item => item[featureList[inputItem]] != null);
  }
  for (let labelItem = 0; labelItem < labelList.length; labelItem++) {
    data = data.filter(item => item[labelList[labelItem]] != null);
  }

  // Step 1. Shuffle the data
  tf.util.shuffle(data);

  // Step 2. Map features and labels to separate arrays
  const inputData = []; const labelData = [];
  const inputs = []; const labels = [];

  // Step 2.1 Map features into the inputData array
  for (let i = 0; i < featureList.length; i++) {
    inputData.push(data.map(d => d[featureList[i]]));
  }
  // Step 2.2 Map labels into the labelData array
  for (let i = 0; i < labelList.length; i++) {
    labelData.push(data.map(d => d[labelList[i]]));
  }
  // Step 3 Convert arrays into multidimensional tensors
  const inputShape = []
}


/**
 * Convert the input data to tensors that we can use for machine
 * learning. We will also do the important best practices of _shuffling_
 * the data and _normalizing_ the data
 * MPG on the y-axis.
 */
function convertToTensor(data, featureName, labelName) {
  // function convertToTensor(data, featureList, labelList)
	// Wrapping these calculations in a tidy will dispose any
	// intermediate tensors.

	return tf.tidy(() => {
	  // Step 0. Drop the null data
		data = data.filter(item =>
			(item['features'][0] != null && item['labels'][0] != null))

		// Step 1. Shuffle the data
		tf.util.shuffle(data);

		// Step 2. Convert data to Tensor
		const inputs = data.map(d => d['features'][0])
		const labels = data.map(d => d['labels'][0]);

		const inputTensor = tf.tensor2d(inputs, [inputs.length, 1]);
		const labelTensor = tf.tensor2d(labels, [labels.length, 1]);

		console.log('input shape: ', inputTensor.shape)
    console.log('label shape: ', labelTensor.shape)

		// Step 3. Normalize the data to the range 0 - 1 using min-max scaling
		const inputMax = inputTensor.max();
		const inputMin = inputTensor.min();
		const labelMax = labelTensor.max();
		const labelMin = labelTensor.min();

		const normalizedInputs = inputTensor.sub(inputMin).div(inputMax.sub(inputMin));
		const normalizedLabels = labelTensor.sub(labelMin).div(labelMax.sub(labelMin));

		// If you want to return a f**kton of data, use a JS object!
		return {
			inputs: normalizedInputs,
			labels: normalizedLabels,
			// Return the min/max bounds so we can use them later.
			inputMax,
			inputMin,
			labelMax,
			labelMin
		}
	})
}

// Create a UI for this!
function createLinearModel () {
	// Create a sequential model
	const model = tf.sequential();

	// Add a single input layer
	model.add(tf.layers.dense({ inputShape: [1], units: 1, useBias: true }));

	// Add an output layer
	model.add(tf.layers.dense({ units: 1, useBias: true }));

	return model;
}


/**
 * Train a TensorFlow.JS model according to the specified model, features,
 * and labels.
 */
async function trainModel(model, inputs, labels) {

	const optimizerType = optimizerSelector.value
	const lossFunction = lossSelector.value
	const trainingMetric = [metricSelector.value]

	console.log(optimizerType)
	console.log(lossFunction)
	console.log(trainingMetric)

	let compileParameters = {}
	compileParameters.optimizer = optimizerType
	compileParameters.loss = lossFunction
	compileParameters.metrics = trainingMetric
	console.log(compileParameters)

	model.compile(compileParameters)

	// Prepare the model for training.
	// model.compile({
		// optimizer: tf.train.adam(), // adam by default
		// loss: tf.losses.meanSquaredError, // mse by default
		// metrics: ['mse'] // mse by default
	// })

	const batchSize = parseInt(batchSizeSelector.value); // 32 by default
	const epochs = parseInt(epochSelector.value); // 50 by default

	// THIS IS ASYNCHRONOUS!
	return await model.fit(inputs, labels, {
		batchSize, // don't define as kwargs!
		epochs,
		shuffle: true,
		// Visualize training performance with loss and mse
		callbacks: tfvis.show.fitCallbacks(
			{ name: 'Training Performance' },
			['loss', 'mse'],
			{ height: 200, callbacks: ['onEpochEnd'] }
		)
	})
}

// THIS IS A SYNCHRONOUS FUNCTION!
function testModel () {
	// normalizationData generated from convertToTensor
	const { inputMax, inputMin, labelMin, labelMax } = tensorData;

	// Generate predictions for a uniform range of numbers between 0 and 1;
	// We un-normalize the data by doing the inverse of the min-max scaling
	// that we did earlier.
	const [xs, preds] = tf.tidy(() => {
		// linspace returns a tensor, not a list
		// ... quite unlike in MATLAB
		const xs = tf.linspace(0, 1, 100)
		// Note that the tensor needs to have a similar shape
		// ([num_examples, num_features_per_example]) as when we did training.
		const preds = model.predict(xs.reshape([100, 1]))

		const unNormXs = xs.mul(inputMax.sub(inputMin)).add(inputMin)

		const unNormPreds = preds.mul(labelMax.sub(labelMin)).add(labelMin)

		/*
		 * Un-normalize the data
		 * .dataSync() is a method we can use to get a typedarray of the
		 * values stored in a tensor. This allows us to process those values in
		 * regular JavaScript. This is a synchronous version of the .data() method
		 * which is generally preferred.
		 */
		return [unNormXs.dataSync(), unNormPreds.dataSync()]
	})

	// Format the original and the predicted data into objects with
	// the same properties to be plotted in one graph
	// Note how "x" and "y" correspond exactly to the scatterplot axes
	const predictedPoints = Array.from(xs).map((val, i) => {
		return { x: val, y: preds[i] }
	})

	const originalPoints = data.map(d => ({
		x: d.horsepower, y: d.mpg,
	}))

	tfvis.render.scatterplot(
		{ name: 'Model Predictions vs Original Data' },
		{
			values: [originalPoints, predictedPoints],
			series: ['original', 'predicted']
		},
		{
			xLabel: 'Horsepower',
			yLabel: 'MPG',
			height: 300
		}
	)
}

async function run() {
	document.getElementById('trainingOutput').innerText = ""
	model = createLinearModel()
	tfvis.show.modelSummary({ name: 'Model Summary' }, model)

	// Prepare data
	// Try figure out the ins and outs of the tfvis module later on!
	// Convert the data to a form we can use for training.
	tensorData = convertToTensor(data, featureName, labelName)
	const { inputs, labels } = tensorData // Read values of properties from the object

	// Train the model
	await trainModel(model, inputs, labels) // ASYNCHRONOUS
	console.log('Done Training')
	document.getElementById('trainingOutput').innerText = "Done Training!"
}


// Try to reformat this...
async function predictValue() {
  predictionInputData = [];
  for (let i = 0; i < predictionInputTrackers.length; i++) {
    // Load input values
    predictionInputData.push(parseFloat(predictionInputTrackers[i].value))
  }
  console.log(predictionInputData)
}

inputField.addEventListener('change', uploadOperation)
viewButton.addEventListener('click', loadAttributes)
confirmButton.addEventListener('click', loadData)

// testMultiple.addEventListener('click', convertArrayToTensor)

trainingStarter.addEventListener('click', run)
testingStarter.addEventListener('click', testModel)
predictionButton.addEventListener('click', predictValue)
