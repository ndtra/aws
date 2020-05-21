package com.dxc.controller;

import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.DefaultAWSCredentialsProviderChain;
import com.amazonaws.services.rekognition.AmazonRekognition;
import com.amazonaws.services.rekognition.AmazonRekognitionClientBuilder;
import com.amazonaws.services.rekognition.model.AmazonRekognitionException;
import com.amazonaws.services.rekognition.model.DetectLabelsRequest;
import com.amazonaws.services.rekognition.model.DetectLabelsResult;
import com.amazonaws.services.rekognition.model.DetectModerationLabelsRequest;
import com.amazonaws.services.rekognition.model.DetectModerationLabelsResult;
import com.amazonaws.services.rekognition.model.DetectTextRequest;
import com.amazonaws.services.rekognition.model.DetectTextResult;
import com.amazonaws.services.rekognition.model.Image;
import com.amazonaws.services.rekognition.model.Label;
import com.amazonaws.services.rekognition.model.ModerationLabel;
import com.amazonaws.services.rekognition.model.S3Object;
import com.amazonaws.services.rekognition.model.TextDetection;
import com.amazonaws.services.translate.AmazonTranslate;
import com.amazonaws.services.translate.AmazonTranslateClient;
import com.amazonaws.services.translate.model.TranslateTextRequest;
import com.amazonaws.services.translate.model.TranslateTextResult;
import com.amazonaws.util.IOUtils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.commons.CommonsMultipartFile;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class HomeController {

	public static boolean isNullOrEmpty(String str) {
		if (str != null && !str.isEmpty())
			return false;
		return true;
	}

	@GetMapping("/")
	public ModelAndView home() {
		ModelAndView mv = new ModelAndView("home");
		return mv;
	}

	@PostMapping("/translate")
	@ResponseBody
	public byte[] translate(@RequestBody String input) {

		if (isNullOrEmpty(input))
			return null;

		AWSCredentialsProvider awsCreds = DefaultAWSCredentialsProviderChain.getInstance();

		AmazonTranslate translate = AmazonTranslateClient.builder()
				.withCredentials(new AWSStaticCredentialsProvider(awsCreds.getCredentials()))
				// .withRegion(DefaultAwsRegionProviderChain.class.getName())
				.build();

		TranslateTextRequest request = new TranslateTextRequest().withText(input).withSourceLanguageCode("en")
				.withTargetLanguageCode("vi");
		TranslateTextResult result = translate.translateText(request);

		String res = result.getTranslatedText();

		System.out.println(res);

		byte[] b = res.getBytes(StandardCharsets.UTF_8);

		return b;
	}

	@PostMapping("/detect-moderation")
	@ResponseBody
	public List<String> detectModeration(@RequestParam CommonsMultipartFile file) throws IOException {
		
		ByteBuffer imageBytes;
        try (InputStream inputStream = file.getInputStream()) {
            imageBytes = ByteBuffer.wrap(IOUtils.toByteArray(inputStream));
        }


        AmazonRekognition rekognitionClient = AmazonRekognitionClientBuilder.defaultClient();
        
        DetectModerationLabelsRequest request = new DetectModerationLabelsRequest()
                .withImage(new Image()
                        .withBytes(imageBytes))
                		.withMinConfidence(60F);;

		try {
			List<String> results = new ArrayList<String>();
			DetectModerationLabelsResult result = rekognitionClient.detectModerationLabels(request);
			List<ModerationLabel> labels = result.getModerationLabels();
			if(labels.size() == 0) {
				results.add("This is not an image that has adult content!");
				return results;
			}
			for (ModerationLabel label : labels) {
				results.add("Label: " + label.getName() + "\n Confidence: " + label.getConfidence().toString()
						+ "%" + "\n Parent:" + label.getParentName());
			}
			return results;
		} catch (AmazonRekognitionException e) {
			e.printStackTrace();
		}
		return null;
	}

	@PostMapping("/detect-text")
	@ResponseBody
	public List<String> detectText(@RequestParam CommonsMultipartFile file) throws IOException {
		//String photo = "inputtext.jpg";
		String bucket = "bucket";

		ByteBuffer imageBytes;
        try (InputStream inputStream = file.getInputStream()) {
            imageBytes = ByteBuffer.wrap(IOUtils.toByteArray(inputStream));
        }


        AmazonRekognition rekognitionClient = AmazonRekognitionClientBuilder.defaultClient();

        DetectTextRequest request = new DetectTextRequest()
                .withImage(new Image()
                        .withBytes(imageBytes));

		try {
			List<String> results = new ArrayList<String>();
			DetectTextResult result = rekognitionClient.detectText(request);
			List<TextDetection> textDetections = result.getTextDetections();
			
			if(textDetections.size() == 0) {
				results.add("This is not an image that has text!");
				return results;
			}

			for (TextDetection text : textDetections) {
				results.add(text.getDetectedText());
			}
			return results;
		} catch (AmazonRekognitionException e) {
			e.printStackTrace();
		}
		return null;
	}

}
