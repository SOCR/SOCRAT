// DEVELOPMENT PLANS FOR APRIL 1
// TODO: Complete Prediction Input
// TODO: Multiple Inputs
// TODO: Layers Specifier (Make something that appears to work...)


console.log("Hello SOCR!")

// File upload button
let inputField = document.getElementById('fileInput')
// Preview of file attributes
let infoField = document.getElementById('fileInfoContainer')
// Submit file and load data
let viewButton = document.getElementById('viewFile')

let featureField = document.getElementById('featureSelection')
let labelField = document.getElementById('labelSelection')
let confirmButton = document.getElementById('confirmSelection')
let dataLoaded = document.getElementById('loadComplete')

let trainingStarter = document.getElementById('trainingStarter')
let testingStarter = document.getElementById('testingStarter')
let predictionInput = document.getElementById('predictionInput')
let predictionButton = document.getElementById('confirmPredictionInput')
let predictionOutput = document.getElementById('predictedValueContainer')

let optimizerSelector = document.getElementById('optimizerSelector')
let lossSelector = document.getElementById('lossSelector')
let metricSelector = document.getElementById('metricSelector')
let batchSizeSelector = document.getElementById('batchSize')
let epochSelector = document.getElementById('epochNumber')

let csvObject;
let file, model, data = [], tensorData;
// let features = [], labels = [];

let featureName, labelName, predictFeature;

let batchSize, epochs;

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

function loadAttributes() {
	// Extract first row from the csv
	// I know that not all data are like this!
	let attributes = csvObject['data'][0]
	if (featureField)
	featureField.innerHTML = "";

	labelField.innerHTML = "";

	for (let i = 0; i < attributes.length; i++) {
		featureField.innerHTML += "<option value = \"" + attributes[i] +
			"\">" + attributes[i] + "</option>";
		labelField.innerHTML += "<option value = \"" + attributes[i] +
			"\">" + attributes[i] + "</option>";
	}

}

function loadData() {
	dataLoaded.innerText = '';

	const featureIndex = featureField.selectedIndex;
	const labelIndex = labelField.selectedIndex;

	let dataItem
	featureName = csvObject['data'][0][featureIndex]
	labelName = csvObject['data'][0][labelIndex]

	// Extract data from the csv object by column
	// Skip first row with the string attributes
	for (let i = 1; i < csvObject['data'].length; i++) {
		dataItem = {}
		dataItem[featureName] = csvObject['data'][i][featureIndex]
		dataItem[labelName] = csvObject['data'][i][labelIndex]
		data.push(dataItem)
	}

	// const datasetSize = data.length;
	dataLoaded.innerText += 'Features and Labels loaded and converted to' +
		' tensors. \n';
	dataLoaded.innerText += 'Total number of feature-label pairs: ' +
		data.length + '\n';
}

/**
 * Convert the input data to tensors that we can use for machine
 * learning. We will also do the important best practices of _shuffling_
 * the data and _normalizing_ the data
 * MPG on the y-axis.
 */
function convertToTensor(data, featureName, labelName) {
	// Wrapping these calculations in a tidy will dispose any
	// intermediate tensors.

	return tf.tidy(() => {
		// Step 0. Drop the null data
		data = data.filter(item =>
			(item[featureName] != null && item[labelName] != null))
    console.log(data)

		// Step 1. Shuffle the data
		// tf.util.shuffle(data);

    // console.log("shuffled data")
    // console.log(data)

		// Step 2. Convert data to Tensor
		const inputs = data.map(d => d[featureName])
		const labels = data.map(d => d[labelName]);

		const inputTensor = tf.tensor2d(inputs, [inputs.length, 1]);
		const labelTensor = tf.tensor2d(labels, [labels.length, 1]);

		console.log(inputTensor.dataSync())

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

async function predictValue() {
  // This can be scaled up to fit a whole set of inputs!
  const shape = [1,1];
  // TODO: normalize input
	predictFeature = tf.tensor([parseFloat(predictionInput.value)], shape)
  console.log(predictFeature)
  // Maybe use data() to flatten array? Does not seem like a good idea...
	model.predict(predictFeature).array().then(array => console.log(array))
  // TODO: unnormalize output
}

inputField.addEventListener('change', uploadOperation)
viewButton.addEventListener('click', loadAttributes)
confirmButton.addEventListener('click', loadData)

trainingStarter.addEventListener('click', run)
testingStarter.addEventListener('click', testModel)
predictionButton.addEventListener('click', predictValue)
