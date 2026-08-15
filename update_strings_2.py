import re

files = [
    "/Users/taqieallah/Desktop/Medsy-iOS/Medsy-Pharmacy/Resources/en.lproj/Localizable.strings",
    "/Users/taqieallah/Desktop/Medsy-iOS/Medsy-Pharmacy/Resources/ar.lproj/Localizable.strings",
    "/Users/taqieallah/Desktop/Medsy-iOS/Medsy/Resources/en.lproj/Localizable.strings",
    "/Users/taqieallah/Desktop/Medsy-iOS/Medsy/Resources/ar.lproj/Localizable.strings"
]

en_strings = """
"pharmacy.chatbot.analytics.metric.request_coverage_rate" = "Coverage Rate";
"pharmacy.chatbot.analytics.status.ready_for_pickup" = "Ready for Pickup";
"""

ar_strings = """
"pharmacy.chatbot.analytics.metric.request_coverage_rate" = "نسبة التغطية";
"pharmacy.chatbot.analytics.status.ready_for_pickup" = "جاهز للاستلام";
"""

keys_to_remove = [
    "pharmacy.chatbot.analytics.metric.request_coverage_rate",
    "pharmacy.chatbot.analytics.status.ready_for_pickup"
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove existing keys
    for key in keys_to_remove:
        content = re.sub(r'^"' + re.escape(key) + r'".*$\n?', '', content, flags=re.MULTILINE)
    
    # Ensure it ends with a newline
    if not content.endswith('\n'):
        content += '\n'
    
    # Append the block
    if 'en.lproj' in file:
        content += en_strings
    else:
        content += ar_strings
        
    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)

print("done")
