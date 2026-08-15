import re

files = [
    "/Users/taqieallah/Desktop/Medsy-iOS/Medsy-Pharmacy/Resources/en.lproj/Localizable.strings",
    "/Users/taqieallah/Desktop/Medsy-iOS/Medsy-Pharmacy/Resources/ar.lproj/Localizable.strings",
    "/Users/taqieallah/Desktop/Medsy-iOS/Medsy/Resources/en.lproj/Localizable.strings",
    "/Users/taqieallah/Desktop/Medsy-iOS/Medsy/Resources/ar.lproj/Localizable.strings"
]

en_strings = """
"pharmacy.chatbot.analytics.metric.requests_received" = "Requests Received";
"pharmacy.chatbot.analytics.metric.requests_covered" = "Requests Covered";
"pharmacy.chatbot.analytics.metric.total_order_value" = "Total Order Value";
"pharmacy.chatbot.analytics.metric.delivered_revenue" = "Delivered Revenue";
"pharmacy.chatbot.analytics.metric.average_order_value" = "Average Order Value";
"pharmacy.chatbot.analytics.metric.largest_order" = "Largest Order";
"pharmacy.chatbot.analytics.metric.orders_generated" = "Orders Generated";
"pharmacy.chatbot.analytics.metric.delivered_orders" = "Delivered Orders";
"pharmacy.chatbot.analytics.metric.cancelled_orders" = "Cancelled Orders";
"pharmacy.chatbot.analytics.metric.offers_created" = "Offers Created";
"pharmacy.chatbot.analytics.metric.accepted_offers" = "Accepted Offers";
"pharmacy.chatbot.analytics.metric.offer_acceptance_rate" = "Acceptance Rate";
"pharmacy.chatbot.analytics.status.accepted" = "Accepted";
"pharmacy.chatbot.analytics.status.partially_accepted" = "Partially Accepted";
"pharmacy.chatbot.analytics.status.rejected" = "Rejected";
"pharmacy.chatbot.analytics.status.ignored" = "Ignored";
"pharmacy.chatbot.analytics.status.pending" = "Pending";
"pharmacy.chatbot.analytics.status.delivered" = "Delivered";
"pharmacy.chatbot.analytics.status.cancelled" = "Cancelled";
"""

ar_strings = """
"pharmacy.chatbot.analytics.metric.requests_received" = "الطلبات المستلمة";
"pharmacy.chatbot.analytics.metric.requests_covered" = "الطلبات المغطاة";
"pharmacy.chatbot.analytics.metric.total_order_value" = "إجمالي قيمة الطلبات";
"pharmacy.chatbot.analytics.metric.delivered_revenue" = "الإيرادات المحصلة";
"pharmacy.chatbot.analytics.metric.average_order_value" = "متوسط قيمة الطلب";
"pharmacy.chatbot.analytics.metric.largest_order" = "أكبر طلب";
"pharmacy.chatbot.analytics.metric.orders_generated" = "الطلبات المُنشأة";
"pharmacy.chatbot.analytics.metric.delivered_orders" = "الطلبات الموصلة";
"pharmacy.chatbot.analytics.metric.cancelled_orders" = "الطلبات الملغاة";
"pharmacy.chatbot.analytics.metric.offers_created" = "العروض المُنشأة";
"pharmacy.chatbot.analytics.metric.accepted_offers" = "العروض المقبولة";
"pharmacy.chatbot.analytics.metric.offer_acceptance_rate" = "معدل القبول";
"pharmacy.chatbot.analytics.status.accepted" = "مقبول";
"pharmacy.chatbot.analytics.status.partially_accepted" = "مقبول جزئياً";
"pharmacy.chatbot.analytics.status.rejected" = "مرفوض";
"pharmacy.chatbot.analytics.status.ignored" = "متجاهل";
"pharmacy.chatbot.analytics.status.pending" = "قيد الانتظار";
"pharmacy.chatbot.analytics.status.delivered" = "تم التوصيل";
"pharmacy.chatbot.analytics.status.cancelled" = "ملغى";
"""

keys_to_remove = [
    "pharmacy.chatbot.analytics.metric.requests_received",
    "pharmacy.chatbot.analytics.metric.requests_covered",
    "pharmacy.chatbot.analytics.metric.total_order_value",
    "pharmacy.chatbot.analytics.metric.delivered_revenue",
    "pharmacy.chatbot.analytics.metric.average_order_value",
    "pharmacy.chatbot.analytics.metric.largest_order",
    "pharmacy.chatbot.analytics.metric.orders_generated",
    "pharmacy.chatbot.analytics.metric.delivered_orders",
    "pharmacy.chatbot.analytics.metric.cancelled_orders",
    "pharmacy.chatbot.analytics.metric.offers_created",
    "pharmacy.chatbot.analytics.metric.accepted_offers",
    "pharmacy.chatbot.analytics.metric.offer_acceptance_rate",
    "pharmacy.chatbot.analytics.status.accepted",
    "pharmacy.chatbot.analytics.status.partially_accepted",
    "pharmacy.chatbot.analytics.status.rejected",
    "pharmacy.chatbot.analytics.status.ignored",
    "pharmacy.chatbot.analytics.status.pending",
    "pharmacy.chatbot.analytics.status.delivered",
    "pharmacy.chatbot.analytics.status.cancelled"
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
