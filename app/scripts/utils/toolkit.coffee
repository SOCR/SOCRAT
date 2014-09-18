toolkit = angular.module 'app.utils.toolkit',[]

toolkit.run([
  ->
    console.log 'run block of app.utils.toolkit'
])

toolkit.factory 'app.utils.toolkit.toCSV',[
  ->
    (data) ->
      #$.toCSV(data) if data?
      data
]
