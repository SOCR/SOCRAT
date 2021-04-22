/*
  Multiple inputs would undoubtedly have to account for the following:
  - Difference in data selection and extraction
  - Difference in model specification
  - Difference in tensor conversion
  - Difference in testing and data prediction UI.
 */

// Compressing / Compiling JavaScript.

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
 * Load data into the feature and label fields according to the attributes
 * selected by the user.
 * FULLY OPTIMIZED FOR MULTIPLE INPUTS/OUTPUTS
 */
function loadData() {

  // HELPER FUNCTION DEFINITION
  /**
   * Convert the multidimensional input data to tensors that we can use for
   * machine learning.
   * We will also do the important best practices of _shuffling_ the data
   * and _normalizing_ the data.
   *
   * TODO: This may not be the most efficient way to loop through a ton of
   *  data
   */
  function convertArrayToTensor(data) {
    // Step -1. Helper function definition
    /**
     * Creates a tensor and normalizes its data from a JavaScript array
     * @param list A one-dimensional JavaScript array
     * @returns {object} An object containing the normalized tensor as well as
     * its extreme values
     */
    function normalizeData(list) {
      const maximum = list.reduce(function(a,b) {return Math.max(a,b)})
      const minimum = list.reduce(function(a,b) {return Math.min(a,b)})
      return {
        array: list.map(item => (item - minimum) / (maximum - minimum)),
        max: maximum,
        min: minimum
      }
    }


    // Step 0. Clean data
    for (let i = 0; i < data[0]['features'].length; i++) {
      data = data.filter(item => (item['features'][i] != null))
    }
    for (let i = 0; i < data[0]['labels'].length; i++) {
      data = data.filter(item => (item['labels'][i] != null))
    }

    // Step 1. Shuffle the data
    // tf.util.shuffle(data);

    // Step 2 Normalized Data
    /** An array of the different tensors of the features. */
    let inputs = [];
    /** An array of the different tensors of the labels. */
    let labels = [];

    for (let i = 0; i < featureSize; i++)
      inputs.push(normalizeData(data.map(d => d['features'][i])));

    for (let i = 0; i < labelSize; i++)
      labels.push(normalizeData(data.map(d => d['labels'][i])));

    console.log(inputs)

    const inputMax = inputs.map(item => item.max)
    const inputMin = inputs.map(item => item.min)
    const labelMax = labels.map(item => item.max)
    const labelMin = labels.map(item => item.min)
    console.log(inputMax, inputMin, labelMax, labelMin);

    let normalizedInputs = []; let normalizedLabels = [];

    for (let i = 0; i < inputs[0]['array'].length; i++) {
      const dataItem = inputs.map(item => item['array'][i])
      normalizedInputs.push(dataItem)
    }

    for (let i = 0; i < labels[0]['array'].length; i++) {
      const dataItem = labels.map(obj => obj['array'][i])
      normalizedLabels.push(dataItem)
    }

    console.log(normalizedInputs)
    console.log(normalizedLabels)

    const inputTensor = tf.tensor2d(normalizedInputs)
    const labelTensor = tf.tensor2d(normalizedLabels)
    inputTensor.print()
    labelTensor.print()

    dataLoaded.innerText += 'inputMax: ' + inputMax.toString() + '\n';
    dataLoaded.innerText += 'inputMin: ' + inputMin.toString() + '\n';
    dataLoaded.innerText += 'labelMax: ' + labelMax.toString() + '\n';
    dataLoaded.innerText += 'labelMin: ' + labelMin.toString() + '\n';

    return {
      inputs: tf.reshape(inputTensor, [normalizedInputs.length, featureSize]),
      labels: tf.reshape(labelTensor, [normalizedLabels.length, labelSize]),
      inputMax, inputMin, labelMax, labelMin
    }

  }

  /**
   * Returns an array of the selected values select is an HTML select element
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
   * @deprecated
   *
   * Coverts a data array into a Tensor2D to be fed into the training model.
   * @param data The 1-D list to be converted
   * @returns {*} A Tensor2D with values corresponding to the above list
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

  tensorData = convertArrayToTensor(data)

	// const datasetSize = data.length;
	dataLoaded.innerText += 'Features and Labels loaded and converted to' +
		' tensors. \n';
	dataLoaded.innerText += 'Total number of feature-label pairs: ' +
		data.length + '\n';

	console.log(tensorData);
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
 */
async function trainModel(model, inputs, labels) {

	const optimizerType = optimizerSelector.value
	const lossFunction = lossSelector.value
	const trainingMetric = [metricSelector.value]

	// console.log(optimizerType)
	// console.log(lossFunction)
	// console.log(trainingMetric)

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


// THIS IS NOT WORKING UNDER MULTIPLE INPUTS
// AT LEAST MAKE IT WORK FOR SINGLE INPUTS, THOUGH
function testModel () {
  /** Helper function to generate testing feature values. */
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
		const unNormXs = xs.mul(inputMax[0].sub(inputMin[0])).add(inputMin[0])
		const unNormPreds = preds.mul(labelMax[0].sub(labelMin[0])).add(labelMin[0])

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
	const { inputs, labels } = tensorData // Read values of properties from the object

	// Train the model
	await trainModel(model, inputs, labels) // ASYNCHRONOUS
	console.log('Done Training')
	document.getElementById('trainingOutput').innerText = "Done Training!"
}


// TODO: great, now this piece of shit is giving me a bunch of NaNs
async function predictValue() {

  // Step 0. Declaration of some useful variables
  predictionOutput.innerText = ""
  let { inputMax, inputMin, labelMax, labelMin } = tensorData;

  predictionInputData = [];
  let normalizedInputData = [], unnormalizedLabels = [];
  const inputShape = [1, predictionInputTrackers.length]

  // Step 1. Read array of input values from test box
  for (let i = 0; i < predictionInputTrackers.length; i++) {
    // Load input values
    const item = parseFloat(predictionInputTrackers[i].value);
    console.log(item);
    predictionInputData.push(item)
  }
  console.log(predictionInputData)

  const preds = tf.tidy(() => {

    // Step 2. Convert input values into a tensor and normalize their values
    for (let i = 0; i < featureSize; i++) {
      let memberMax = inputMax[i];
      let memberMin = inputMin[i];
      normalizedInputData.push(
        (predictionInputData[i] - memberMin) / (memberMax - memberMin)
      );
    }
    console.log(normalizedInputData);
    const xs = tf.tensor(normalizedInputData, inputShape);

    // Step 3. Make predictions from the model
    // TODO: Consider the original async function?
    const preds = model.predict(xs).dataSync()

    // Step 4. Unnormalize the preicted labels
    // const unNormXs = xs.mul(inputMax.sub(inputMin)).add(inputMin)
    for (let i = 0; i < labelSize; i++) {
      let memberMax = labelMax[i];
      let memberMin = labelMin[i];
      unnormalizedLabels.push(preds[i] * (memberMax - memberMin) + memberMin);
    }
    return unnormalizedLabels;

  })

  // Step 5. Show the results in the user interface
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
