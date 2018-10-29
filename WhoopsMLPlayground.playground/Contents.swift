import CreateML
import Foundation

print(Date())
let dataUrl = URL(fileURLWithPath: "/Users/annakoczur/Desktop/Dataset_preparation/SisFall_dataset/result_dataset_binary.csv")
let dataset = try MLDataTable(contentsOf: dataUrl)
let classifier = try MLClassifier(trainingData: dataset, targetColumn: "label")
let trainingMetrics = classifier.trainingMetrics
let validationMetrics = classifier.validationMetrics
print(classifier.model)
print(Date())

try classifier.write(to: URL(fileURLWithPath: "/Users/annakoczur/Desktop/Whoops.mlmodel"),
metadata: MLModelMetadata(author: "Anna Koczur",
shortDescription: "Fall detection Classification Model trained on the SisFall dataset",
license: nil,
version: "1.0",
additional: nil))
