
 import '../event.dart';
import 'bucket.dart';
import 'bucket_factory.dart';

interface class  BucketSplitter<B extends Bucket, E extends Event> {

	List<B> split(BucketFactory<B> factory, List<E> data, int threshold){
		throw Error();
	}

}
