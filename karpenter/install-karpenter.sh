#export TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
export CLUSTER_NAME="workshop-cluster"
export AWS_REGION="us-west-2"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --profile default --query Account --output text)"
export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output text --profile default)"
export KARPENTER_NAMESPACE="kube-system"

echo Cluster Name:$CLUSTER_NAME AWS Region:$AWS_REGION Account ID:$AWS_ACCOUNT_ID Cluster Endpoint:$CLUSTER_ENDPOINT Karpenter Namespace:$KARPENTER_NAMESPACE


exit 

echo Your Karpenter version is: $KARPENTER_VERSION
#
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version 1.5.1 \
  --namespace "kube-system" \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn=arn:aws:iam::103891662525:role/workshop-cluster-karpenter" \
  --set settings.clusterName=workshop-cluster \
  --set settings.clusterEndpoint=https://3DE5620BC9016713EA195E8393080F7E.gr7.us-west-2.eks.amazonaws.com \
  --set settings.featureGates.spotToSpotConsolidation=true \
  --set settings.interruptionQueue=workshop-cluster \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi \
  --set controller.podDnsPolicy=Default \
  --timeout 10m \
  --wait --debug --dry-run