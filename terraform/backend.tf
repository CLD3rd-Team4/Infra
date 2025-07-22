terraform { 
  cloud { 
    organization = "FinalProject-Team4" 
  }

  # CLI에서 워크스페이스 전환
  # 1. terraform login 
  # 2. terraform workspace select dev (혹은 staging,prod)
}