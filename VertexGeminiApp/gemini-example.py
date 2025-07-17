import vertexai
from vertexai.generative_models import GenerativeModel, Part, ChatSession

def chat_with_gemini_2_5_flash(project_id: str, location: str):
    """
    Gemini 2.5 Flash 모델을 사용하여 채팅 챗봇을 구현합니다.

    Args:
        project_id (str): Google Cloud 프로젝트 ID.
        location (str): Vertex AI 모델이 배포된 리전 (예: "us-central1").
    """

    vertexai.init(project=project_id, location=location)

    # Gemini 2.5 Flash 모델 초기화
    # 안정화 버전은 'gemini-2.5-flash'를 사용합니다.
    # 프리뷰 버전을 사용하려면 'gemini-2.5-flash-preview-05-20' 또는 최신 프리뷰 버전을 지정할 수 있습니다.
    model = GenerativeModel("gemini-2.5-flash")

    # 채팅 세션 시작
    chat = model.start_chat()

    print("Gemini 2.5 Flash 챗봇입니다. 대화를 시작하세요. '종료'를 입력하여 종료할 수 있습니다.")

    while True:
        user_message = input("당신: ")
        if user_message.lower() == '종료':
            print("챗봇을 종료합니다.")
            break

        try:
            # 챗봇 응답 생성
            # stream=True로 설정하면 응답을 스트리밍 방식으로 받을 수 있습니다.
            # generation_config를 통해 모델의 응답 방식을 제어할 수 있습니다.
            responses = chat.send_message(
                user_message,
                generation_config={
                    "max_output_tokens": 8192, # 최대 출력 토큰 수
                    "temperature": 0.9,       # 창의성 조절 (높을수록 창의적)
                    "top_p": 1.0,             # Top-P 샘플링
                    "top_k": 32               # Top-K 샘플링
                },
                stream=True # 실시간 스트리밍
            )

            print("챗봇:", end=" ")
            for response in responses:
                print(response.text, end="")
            print() # 다음 줄로 넘어가기

        except Exception as e:
            print(f"오류가 발생했습니다: {e}")
            print("다시 시도해 주세요.")

if __name__ == "__main__":
    # TODO: YOUR_PROJECT_ID를 실제 Google Cloud 프로젝트 ID로 변경하세요.
    # TODO: YOUR_LOCATION을 Vertex AI 모델을 사용할 리전으로 변경하세요 (예: "us-central1").
    your_project_id = "sesac-dev-400904"
    your_location = "us-central1" # 또는 "asia-east1", "europe-west1" 등
    chat_with_gemini_2_5_flash(your_project_id, your_location)
