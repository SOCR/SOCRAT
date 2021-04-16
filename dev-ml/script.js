/*
  Multiple inputs would undoubtedly have to account for the following:
  - Difference in data selection and extraction
  - Difference in model specification
  - Difference in tensor conversion
  - Difference in testing and data prediction UI.
 */

// DOES NOT WORK
// import * as tbjs from './node_modules/@tensorflow/tfjs-node/dist/tensorboard.js'


fetch('README.md')
  .then(response => response.text())
  .then(text => console.log(text))


// File upload button
let inputField = document.getElementById('fileInput')
// Preview of file attributes
let infoField = document.getElementById('fileInfoContainer')
// Submit file and load data
let viewButton = document.getElementById('viewFile')

// Set of fields for selecting and loading feature and label data
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

let featureSize, labelSize;
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
  var n = new Date(Date.now());
  console.log("Upload completed at " + n.toISOString());

	// TODO: Implement all these parameters as customizable UI Interfaces!
	Papa.parse(file, {
		// TODO: Batch processing for ridiculously large csv files?
		// TODO: Implement customizable dynamic typing in the near future
		dynamicTyping : true,
		complete: function(results) {
			// console.log(results);
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
 * selected by the user.
 * FULLY OPTIMIZED FOR MULTIPLE INPUTS/OUTPUTS
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
  featureSize = featureList.length;
  labelSize = labelList.length;

	console.log("featureList: ", featureList)
  console.log("labelList: ", labelList)
  console.log("featureIndices: ", featureIndices)
  console.log("labelIndices: ", labelIndices)

	// Load prediction parameters
  modelPredictionContainer.innerHTML = "";
  predictionInputTrackers = [];
  for (let i=0; i < featureList.length; i++) {
    // Add lines looking like the following to
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
   *
   * Meanwhile, the data object would contain a list of dataItems in the
   *  above format.
   */
  // Extract data from the csv object by column
  // Skip first row with the string attributes
  for (let i = 1; i < csvObject['data'].length; i++) {
    let dataItem = {}
    dataItem['features'] = featureIndices.map(x => csvObject['data'][i][x])
    dataItem['labels'] = labelIndices.map(x => csvObject['data'][i][x])
    // if (i == 1) console.log(dataItem) // for debugging
    data.push(dataItem)
  }

	// const datasetSize = data.length;
	dataLoaded.innerText += 'Features and Labels loaded and converted to' +
		' tensors. \n';
	dataLoaded.innerText += 'Total number of feature-label pairs: ' +
		data.length + '\n';

	console.log(data)
}


/**
 * Creates a tensor and normalizes its data from a JavaScript array
 * @param list A one-dimensional JavaScript array
 * @returns {object} An object containing the normalized tensor as well as
 * its extreme values
 */
function normalizeData(list) {
  let listTensor = tf.tensor2d(list, [list.length, 1])
  const maximum = listTensor.max()
  const minimum = listTensor.min()
  return {
    array: listTensor.sub(minimum).div(maximum.sub(minimum)).dataSync(),
    max: maximum,
    min: minimum
  }
}


// TODO: This may not be the most efficient way to loop through a f**kton of
//  data
function convertArrayToTensor(data) {
  // Step 0. Clean data
  for (let i = 0; i < data[0]['features'].length; i++) {
    data = data.filter(item => (item['features'][i] != null))
  }
  for (let i = 0; i < data[0]['labels'].length; i++) {
    data = data.filter(item => (item['labels'][i] != null))
  }

  // Step 1. Shuffle the data
  // tf.util.shuffle(data);

  // Step 2 Convert data objects to tensors
  /* Each of the data fields in inputs and labels follow the following format:
   * {
   *   tensor: a normalized tensor
   *   max: its maximum value
   *   min: its minimum value
   * }
   */
  /** An array of the different tensors of the features. */
  let inputs = [];
  /** An array of the different tensors of the labels. */
  let labels = [];

  for (let i = 0; i < featureSize; i++) {
    const list = data.map(d => d['features'][i])
    inputs.push(normalizeData(list))
  }
  for (let i = 0; i < labelSize; i++) {
    const list = data.map(d => d['labels'][i])
    labels.push(normalizeData(list))
  }

  console.log(inputs)

  const inputMax = inputs.map(item => item.max)
  const inputMin = inputs.map(item => item.min)
  const labelMax = labels.map(item => item.max)
  const labelMin = labels.map(item => item.min)

  let normalizedInputs = []; let normalizedLabels = [];
  for (let i = 0; i < featureSize; i++) {
    const dataItem = inputs.map(obj => obj['array'])
    normalizedInputs.push(dataItem);
  }
  for (let i = 0; i < labelSize; i++) {
    const dataItem = labels.map(obj => obj['array'])
    normalizedLabels.push(dataItem);
  }

  console.log(normalizedInputs)
  console.log(normalizedLabels)

  const inputTensor = tf.tensor2d(normalizedInputs[0])
  const labelTensor = tf.tensor2d(normalizedLabels[0])
  inputTensor.print()
  labelTensor.print()

  return {
    inputs: tf.reshape(inputTensor, [normalizedInputs[0][0].length, featureSize]),
    labels: tf.reshape(labelTensor, [normalizedLabels[0][0].length, labelSize]),
    inputMax, inputMin, labelMax, labelMin
  }


}


/**
 * Convert the 1-D input data to tensors that we can use for machine
 * learning. We will also do the important best practices of _shuffling_
 * the data and _normalizing_ the data
 * MPG on the y-axis.
 */
function convertToTensor(data) {
  // function convertToTensor(data, featureList, labelList)

	// Wrapping these calculations in a tidy will dispose any
	// intermediate tensors.

	return tf.tidy(() => {
	  // Step 0. Drop the null data
		data = data.filter(item =>
			(item['features'][0] != null && item['labels'][0] != null))
    console.log(data)

		// Step 1. Shuffle the data
		// tf.util.shuffle(data);

		// Step 2. Convert data to Tensor
		const inputs = data.map(d => d['features'][0])
		const labels = data.map(d => d['labels'][0]);
    // const inputs = data.map(d => d['features'])
    // const labels = data.map(d => d['labels']);

		const inputTensor = tf.tensor2d(inputs, [inputs.length, 1]);
		const labelTensor = tf.tensor2d(labels, [labels.length, 1]);

		// Step 3. Normalize the data to the range 0 - 1 using min-max scaling
		const inputMax = inputTensor.max();
		const inputMin = inputTensor.min();
		const labelMax = labelTensor.max();
		const labelMin = labelTensor.min();

		const normalizedInputs = inputTensor.sub(inputMin).div(inputMax.sub(inputMin));
		const normalizedLabels = labelTensor.sub(labelMin).div(labelMax.sub(labelMin));

		// If you want to return a f**kton of data, use a JS object!
		return {
			inputs: normalizedInputs, labels: normalizedLabels,
			// Return the min/max bounds so we can use them later.
			inputMax, inputMin, labelMax, labelMin
		}
	})
}

// Create a UI for this!
// TODO: This only works for linear-regression like supervised learning at
//  this point!
function createLinearModel () {
	// Create a sequential model
	const model = tf.sequential();

	// Add a single input layer
	model.add(tf.layers.dense({ inputShape: [featureSize], units: featureSize, useBias: true }));

	// Add an output layer
	model.add(tf.layers.dense({ units: labelSize, useBias: true }));

	return model;
}


/**
 * Train a TensorFlow.JS model according to the specified model, features,
 * and labels.
 *
 * THIS IS JUST A WHOLE PIECE OF HORSESHIT CODE!!
 * YOU DON'T JUST TEST OUT MPG AND HORSEPOWER!!
 */
async function trainModel(model, inputs, labels) {

	const optimizerType = optimizerSelector.value
	const lossFunction = lossSelector.value
	const trainingMetric = [metricSelector.value]

	console.log(optimizerType)
	console.log(lossFunction)
	console.log(trainingMetric)

	let compileParameters = {}
	compileParameters.optimizer = optimizerType // adam by default
	compileParameters.loss = lossFunction // mse by default
	compileParameters.metrics = trainingMetric // mse by default
	// console.log(compileParameters)

	model.compile(compileParameters)

	const batchSize = parseInt(batchSizeSelector.value); // 32 by default
	const epochs = parseInt(epochSelector.value); // 50 by default

  // For tensorboard visualization -- doesn't seem to work without node
  // const currentTime = new Date(Date.now())
  // const timestamp = currentTime.toISOString()
  // const logDir = "logs/fit/" + timestamp
  // const tensorBoardCallback = tf.node.tensorBoard(logDir)

	// THIS IS ASYNCHRONOUS!
	return await model.fit(inputs, labels, {
		batchSize, // don't define as kwargs!
		epochs,
		shuffle: true,
		// Visualize training performance with loss and mse
		callbacks:
        // tensorBoardCallback // DOES NOT WORK
      tfvis.show.fitCallbacks(
        { name: 'Training Performance' },
        ['loss', 'mse'],
        { height: 200, callbacks: ['onEpochEnd'] }
		  )
	})
}




function generateTestingData() {
  /**
   * Works just like the linspace() function in TensorFlow.JS or MATLAB
   * @param startValue The least value in the series, inclusive
   * @param stopValue The greatest value in the series, inclusive
   * @param cardinality Size of array to be generated
   * @returns {[]}
   */
  function linspace(startValue, stopValue, cardinality) {
    var arr = [];
    var step = (stopValue - startValue) / (cardinality - 1);
    for (var i = 0; i < cardinality; i++) {
      arr.push(startValue + (step * i));
    }
    return arr;
  }

  const testArr = linspace(0, 1, 100).map(item => {
    let itemVec = [];
    for (let i = 0; i < featureSize; i++) itemVec.push(item);
    return itemVec;
  })
  let testTensor = tf.tensor2d(testArr);
  return testTensor;
}


function testModel () {
	// normalizationData generated from convertToTensor
	const { inputMax, inputMin, labelMin, labelMax } = tensorData;

	// Generate predictions for a uniform range of numbers between 0 and 1;
	// We un-normalize the data by doing the inverse of the min-max scaling
	// that we did earlier.
	const [xs, preds] = tf.tidy(() => {
		// linspace returns a tensor, not a list
		// ... quite unlike in MATLAB
    // TODO: Generate multiple xs-es for multiple inputs
		const xs = generateTestingData();
		// Note that the tensor needs to have a similar shape
		// ([num_examples, num_features_per_example]) as when we did training.
    // TODO: The shape has to change!
    tf.reshape(xs, [100, featureSize])
    xs.print()
		const preds = model.predict(xs)

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

  // REDO THIS!!!!!
	const originalPoints = data.map(d => ({
		x: d.features[0], y: d.labels[0],
	}))

  // TODO: HOW DO YOU PLOT MULTIDIMENSIONAL LABELS?
	tfvis.render.scatterplot(
		{ name: 'Model Predictions vs Original Data' },
		{
			values: [originalPoints, predictedPoints],
			series: ['original', 'predicted']
		},
		{
			xLabel: 'Features',
			yLabel: 'Labels',
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
	// tensorData = convertToTensor(data)
  tensorData = convertArrayToTensor(data)
	const { inputs, labels } = tensorData // Read values of properties from the object

	// Train the model
	await trainModel(model, inputs, labels) // ASYNCHRONOUS
	console.log('Done Training')
	document.getElementById('trainingOutput').innerText = "Done Training!"
}


// Try to reformat this...
async function predictValue() {
  predictionOutput.innerText = ""
  const { inputMax, inputMin, labelMin, labelMax } = tensorData;
  predictionInputData = [];
  const inputShape = [1, predictionInputTrackers.length]
  for (let i = 0; i < predictionInputTrackers.length; i++) {
    // Load input values
    predictionInputData.push(parseFloat(predictionInputTrackers[i].value))
  }
  // console.log(predictionInputData)

  // Single value prediction only!
  // Generate predictions for a uniform range of numbers between 0 and 1;
  // We un-normalize the data by doing the inverse of the min-max scaling
  // that we did earlier.
  const preds = tf.tidy(() => {
    const xs = tf.tensor(predictionInputData, inputShape)
        .sub(inputMin).div(inputMax.sub(inputMin));
    const preds = model.predict(xs)
    // const unNormXs = xs.mul(inputMax.sub(inputMin)).add(inputMin)
    const unNormPreds = preds.mul(labelMax.sub(labelMin)).add(labelMin)

    /*
     * Un-normalize the data
     * .dataSync() is a method we can use to get a typedarray of the
     * values stored in a tensor. This allows us to process those values in
     * regular JavaScript. This is a synchronous version of the .data() method
     * which is generally preferred.
     */
    return unNormPreds.dataSync()
  })

  console.log(preds)
  predictionOutput.innerText += preds;
}

inputField.addEventListener('change', uploadOperation)
viewButton.addEventListener('click', loadAttributes)
confirmButton.addEventListener('click', loadData)

// testMultiple.addEventListener('click', convertArrayToTensor)

trainingStarter.addEventListener('click', run)
testingStarter.addEventListener('click', testModel)
predictionButton.addEventListener('click', predictValue)
