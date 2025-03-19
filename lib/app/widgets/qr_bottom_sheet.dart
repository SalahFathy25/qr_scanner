import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

void qrBottomSheet({
  required BuildContext context,
  required TextEditingController titleController,
  required TextEditingController dataController,
  String? existingTitle,
  String? existingData,
  int? index,
  bool iswhatsapp = false,
  required Color buttonColor,
  required void Function() onPressed,
}) {
  bool isEditing = existingTitle != null;

  if (isEditing) {
    titleController.text = existingTitle;
    dataController.text = existingData!;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? "Edit QR Code" : "Add QR Code",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(70, 30),
                    alignment: Alignment.center,
                  ),
                  onPressed: onPressed,
                  child: Text(isEditing ? "Update" : "Add"),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              "Enter Title",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.title),
                hintText: 'Enter Title',
                labelText: 'Title',
              ),
              controller: titleController,
            ),
            SizedBox(height: 15),
            Text(
              "Enter Data",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            iswhatsapp
                ? IntlPhoneField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: 'WhatsApp Number',
                      hintText: 'Enter your WhatsApp Number',
                    ),
                    initialCountryCode: 'EG',
                    initialValue: isEditing ? existingData : null,
                    onChanged: (phone) {
                      dataController.text = phone.completeNumber;
                    },
                  )
                : TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: Icon(Icons.qr_code),
                      hintText: 'Enter Data',
                      labelText: 'Data',
                    ),
                    controller: dataController,
                  ),
            SizedBox(height: 15),
          ],
        ),
      );
    },
  );
}
