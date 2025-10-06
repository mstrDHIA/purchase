
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json

# Debug endpoint to log the received POST body
@csrf_exempt
def debug_purchase_order(request):
	if request.method == 'POST':
		try:
			data = json.loads(request.body.decode('utf-8'))
			print('DEBUG BACKEND - Received body:')
			print(json.dumps(data, indent=2))
			return JsonResponse({'status': 'ok', 'received': data})
		except Exception as e:
			print('DEBUG BACKEND - Error parsing body:', str(e))
			return JsonResponse({'status': 'error', 'error': str(e)}, status=400)
	return JsonResponse({'status': 'only POST allowed'}, status=405)
